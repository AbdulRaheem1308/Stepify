import { IsString, IsOptional, IsPhoneNumber, IsEmail, Length, ValidateIf } from 'class-validator';

export class SendOtpDto {
    @IsOptional()
    @IsPhoneNumber()
    phone?: string;

    @IsOptional()
    @IsEmail()
    email?: string;
}

export class VerifyOtpDto {
    @IsOptional()
    @IsPhoneNumber()
    phone?: string;

    @IsOptional()
    @IsEmail()
    email?: string;

    @IsString()
    @Length(4, 8)
    otp: string;
}

export class RefreshTokenDto {
    @IsString()
    refreshToken: string;
}

export class SocialLoginDto {
    @IsString()
    idToken: string;
}
