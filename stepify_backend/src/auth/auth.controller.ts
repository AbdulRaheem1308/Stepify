import { Controller, Post, Body, UseGuards, Req, HttpCode, HttpStatus } from '@nestjs/common';
import { AuthService } from './auth.service';
import { SendOtpDto, VerifyOtpDto, RefreshTokenDto } from './dto/auth.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';

@Controller('auth')
export class AuthController {
    constructor(private authService: AuthService) { }

    /**
     * Send OTP to phone or email
     * POST /api/v1/auth/send-otp
     */
    @Post('send-otp')
    @HttpCode(HttpStatus.OK)
    async sendOtp(@Body() dto: SendOtpDto) {
        return this.authService.sendOtp(dto);
    }

    /**
     * Verify OTP and return tokens
     * POST /api/v1/auth/verify-otp
     */
    @Post('verify-otp')
    @HttpCode(HttpStatus.OK)
    async verifyOtp(@Body() dto: VerifyOtpDto) {
        return this.authService.verifyOtp(dto);
    }

    /**
     * Social Login (Google/Apple)
     * POST /api/v1/auth/social-login
     */
    @Post('social-login')
    @HttpCode(HttpStatus.OK)
    async socialLogin(@Body() dto: { idToken: string }) {
        return this.authService.loginWithSocial(dto.idToken);
    }



    /**
     * Refresh access token
     * POST /api/v1/auth/refresh
     */
    @Post('refresh')
    @HttpCode(HttpStatus.OK)
    async refresh(@Body() dto: RefreshTokenDto) {
        return this.authService.refreshToken(dto);
    }

    /**
     * Logout - invalidate tokens
     * POST /api/v1/auth/logout
     */
    @Post('logout')
    @UseGuards(JwtAuthGuard)
    @HttpCode(HttpStatus.OK)
    async logout(@Body() dto: RefreshTokenDto) {
        await this.authService.logout(dto.refreshToken);
        return { message: 'Logged out successfully' };
    }
}
