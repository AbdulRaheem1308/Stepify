import { IsString, IsOptional, IsUrl, MinLength } from "class-validator";
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";

export class CreateCompanyDto {
  @ApiProperty({ example: "Tech Corp", description: "Name of the company" })
  @IsString()
  @MinLength(2)
  name: string;

  @ApiProperty({ example: "techcorp.com", description: "Company domain" })
  @IsString()
  domain: string;

  @ApiPropertyOptional({
    example: "https://example.com/logo.png",
    description: "Company logo URL",
  })
  @IsOptional()
  @IsUrl()
  logoUrl?: string;

  @ApiPropertyOptional({
    example: "TECH2024",
    description: "Optional custom invite code",
  })
  @IsOptional()
  @IsString()
  inviteCode?: string;
}

export class JoinCompanyDto {
  @ApiPropertyOptional({
    description: "Optional user ID to join for (Admin only)",
  })
  @IsOptional()
  @IsString()
  userId?: string;
}
