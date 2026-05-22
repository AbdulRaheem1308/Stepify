import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsNumber,
  IsDateString,
  IsEnum,
  IsUrl,
} from "class-validator";
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { OfferType } from "@prisma/client";

export class CreateOfferDto {
  @ApiProperty({ example: "Watch Video", description: "Title of the offer" })
  @IsString()
  @IsNotEmpty()
  title: string;

  @ApiProperty({
    example: "Watch a 30s ad to earn coins",
    description: "Offer description",
  })
  @IsString()
  @IsNotEmpty()
  description: string;

  @ApiProperty({ example: "AdMob", description: "Provider name" })
  @IsString()
  @IsNotEmpty()
  providerName: string;

  @ApiProperty({ example: 50, description: "Reward coins for completion" })
  @IsNumber()
  @IsNotEmpty()
  rewardCoins: number;

  @ApiPropertyOptional({
    enum: OfferType,
    example: "WATCH_TO_EARN",
    description: "Type of offer",
  })
  @IsEnum(OfferType)
  @IsOptional()
  offerType?: OfferType;

  @ApiPropertyOptional({
    example: "https://example.com/image.png",
    description: "Offer image URL",
  })
  @IsUrl()
  @IsOptional()
  imageUrl?: string;

  @ApiPropertyOptional({
    example: "https://example.com/action",
    description: "Action URL",
  })
  @IsUrl()
  @IsOptional()
  actionUrl?: string;

  @ApiPropertyOptional({
    example: "2026-12-31T23:59:59Z",
    description: "Expiry date of the offer",
  })
  @IsDateString()
  @IsOptional()
  expiryDate?: Date;
}
