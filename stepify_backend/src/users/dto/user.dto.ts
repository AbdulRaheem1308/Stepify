import {
  IsString,
  IsOptional,
  IsNumber,
  IsEmail,
  IsPhoneNumber,
  Min,
  Max,
  IsArray,
} from "class-validator";

export class CreateUserDto {
  @IsOptional()
  @IsPhoneNumber()
  phone?: string;

  @IsOptional()
  @IsEmail()
  email?: string;

  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsString()
  referredBy?: string;
}

export class UpdateUserDto {
  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsNumber()
  @Min(50)
  @Max(300)
  heightCm?: number;

  @IsOptional()
  @IsNumber()
  @Min(20)
  @Max(500)
  weightKg?: number;

  @IsOptional()
  @IsNumber()
  @Min(5)
  @Max(120)
  age?: number;

  @IsOptional()
  @IsNumber()
  @Min(1000)
  @Max(100000)
  dailyStepGoal?: number;

  @IsOptional()
  @IsString()
  avatarUrl?: string;

  @IsOptional()
  @IsPhoneNumber()
  phone?: string;

  @IsOptional()
  @IsEmail()
  email?: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  activityPreferences?: string[];

  @IsOptional()
  @IsString()
  fitnessLevel?: string;
}
