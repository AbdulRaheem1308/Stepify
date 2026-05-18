import { Injectable, UnauthorizedException, BadRequestException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../prisma/prisma.service';
import { RedisService } from '../redis/redis.service';
import { OtpService } from './otp.service';
import { UsersService } from '../users/users.service';
import { SendOtpDto, VerifyOtpDto, RefreshTokenDto } from './dto/auth.dto';
import { SocialAuthService } from './social-auth.service';

export interface JwtPayload {
    sub: string;
    phone?: string;
    email?: string;
}

export interface AuthTokens {
    accessToken: string;
    refreshToken: string;
}

@Injectable()
export class AuthService {
    constructor(
        private jwtService: JwtService,
        private configService: ConfigService,
        private prisma: PrismaService,
        private redis: RedisService,
        private otpService: OtpService,
        private socialAuth: SocialAuthService,
        private usersService: UsersService,
    ) { }

    /**
     * Send OTP to phone or email
     */
    async sendOtp(dto: SendOtpDto): Promise<{ message: string; expiresIn: number }> {
        const identifier = dto.phone || dto.email;
        if (!identifier) {
            throw new BadRequestException('Phone or email is required');
        }

        // Check rate limit
        const canSend = await this.redis.checkOtpRateLimit(identifier);
        if (!canSend) {
            throw new BadRequestException('Too many OTP requests. Please try again later.');
        }

        // Generate and store OTP
        const otp = this.otpService.generateOtp();
        const expiryMinutes = this.configService.get<number>('OTP_EXPIRY_MINUTES', 5);

        await this.redis.setOtp(identifier, otp, expiryMinutes);

        // Send OTP via Twilio/Email
        if (dto.phone) {
            await this.otpService.sendSmsOtp(dto.phone, otp);
        } else if (dto.email) {
            await this.otpService.sendEmailOtp(dto.email, otp);
        }

        return {
            message: `OTP sent to ${dto.phone ? 'phone' : 'email'}`,
            expiresIn: expiryMinutes * 60,
        };
    }

    /**
     * Verify OTP and return tokens
     */
    async verifyOtp(dto: VerifyOtpDto): Promise<{ tokens: AuthTokens; user: any; isNewUser: boolean }> {
        const identifier = dto.phone || dto.email;
        if (!identifier) {
            throw new BadRequestException('Phone or email is required');
        }

        // Get stored OTP
        const storedOtp = await this.redis.getOtp(identifier);
        if (!storedOtp) {
            throw new UnauthorizedException('OTP expired or not found');
        }

        // Verify OTP
        if (storedOtp !== dto.otp) {
            throw new UnauthorizedException('Invalid OTP');
        }

        // Delete used OTP
        await this.redis.deleteOtp(identifier);

        // Find or create user
        let user = await this.usersService.findByIdentifier(identifier);
        let isNewUser = false;

        if (!user) {
            user = await this.usersService.create({
                phone: dto.phone,
                email: dto.email,
            });
            isNewUser = true;
        } else if (!user.name) {
            // Treat as new user if profile is incomplete (no name)
            isNewUser = true;
        }

        // Generate tokens
        const tokens = await this.generateTokens(user);

        return {
            tokens,
            user: this.usersService.sanitizeUser(user),
            isNewUser,
        };
    }




    /**
     * Social Login (Google/Apple) via Firebase ID Token
     */
    async loginWithSocial(idToken: string): Promise<{ tokens: AuthTokens; user: any; isNewUser: boolean }> {
        // 1. Verify Token with Firebase Admin
        const decodedToken = await this.socialAuth.verifyIdToken(idToken);
        const { email, picture, name, uid } = decodedToken;

        if (!email) {
            throw new BadRequestException('Social account must have an email address');
        }

        // 2. Find or Create User
        let user = await this.usersService.findByIdentifier(email);
        let isNewUser = false;

        if (!user) {
            user = await this.usersService.create({
                email: email,
                name: name || undefined,
            });
            isNewUser = true;
        }

        // 3. Generate Tokens
        const tokens = await this.generateTokens(user);

        return {
            tokens,
            user: this.usersService.sanitizeUser(user),
            isNewUser,
        };
    }

    /**
     * Refresh access token
     */
    async refreshToken(dto: RefreshTokenDto): Promise<AuthTokens> {
        try {
            // Verify refresh token
            const payload = this.jwtService.verify(dto.refreshToken, {
                secret: this.configService.get('JWT_REFRESH_SECRET'),
            });

            // Check if token exists in database
            const tokenRecord = await this.prisma.refreshToken.findUnique({
                where: { token: dto.refreshToken },
                include: { user: true },
            });

            if (!tokenRecord || tokenRecord.expiresAt < new Date()) {
                throw new UnauthorizedException('Invalid refresh token');
            }

            // Delete old refresh token
            await this.prisma.refreshToken.delete({
                where: { id: tokenRecord.id },
            });

            // Generate new tokens
            return this.generateTokens(tokenRecord.user);
        } catch (error) {
            throw new UnauthorizedException('Invalid refresh token');
        }
    }

    /**
     * Logout - invalidate refresh token
     */
    async logout(refreshToken: string): Promise<void> {
        await this.prisma.refreshToken.deleteMany({
            where: { token: refreshToken },
        });
    }

    /**
     * Generate access and refresh tokens
     */
    private async generateTokens(user: any): Promise<AuthTokens> {
        const payload: JwtPayload = {
            sub: user.id,
            phone: user.phone,
            email: user.email,
        };

        const accessToken = this.jwtService.sign(payload);

        const refreshToken = this.jwtService.sign(payload, {
            secret: this.configService.get('JWT_REFRESH_SECRET'),
            expiresIn: this.configService.get('JWT_REFRESH_EXPIRY', '7d'),
        });

        // Store refresh token in database
        const expiresAt = new Date();
        expiresAt.setDate(expiresAt.getDate() + 7); // 7 days

        await this.prisma.refreshToken.create({
            data: {
                token: refreshToken,
                userId: user.id,
                expiresAt,
            },
        });

        return { accessToken, refreshToken };
    }

    /**
     * Validate user from JWT payload
     */
    async validateUser(payload: JwtPayload): Promise<any> {
        const user = await this.usersService.findById(payload.sub);
        if (!user || !user.isActive) {
            throw new UnauthorizedException();
        }
        return user;
    }
}
