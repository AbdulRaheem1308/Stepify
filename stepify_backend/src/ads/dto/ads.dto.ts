import { IsString, IsOptional, IsEnum } from "class-validator";
import { AdType } from "@prisma/client";
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";

export class ClaimAdRewardDto {
  @ApiProperty({ description: "Type of ad watched", enum: AdType })
  @IsEnum(AdType)
  adType: AdType;

  @ApiPropertyOptional({ description: "Identifier for the ad unit" })
  @IsOptional()
  @IsString()
  adUnitId?: string;
}
