import {
  IsNumber,
  IsString,
  IsOptional,
  IsDateString,
  Min,
  IsBoolean,
  IsObject,
  ValidateNested,
} from "class-validator";
import { Type } from "class-transformer";
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";

export class DeviceIntegrityDto {
  @ApiProperty({
    description: "Indicates if the device has been rooted or jailbroken",
    example: false,
  })
  @IsBoolean()
  isJailBroken: boolean;

  @ApiProperty({
    description: "Indicates if the app is running on a real physical device",
    example: true,
  })
  @IsBoolean()
  isRealDevice: boolean;

  @ApiProperty({
    description: "Indicates if mock location provider or spoofing is active",
    example: false,
  })
  @IsBoolean()
  isMockLocation: boolean;
}

export class SyncStepsDto {
  @ApiProperty({
    description:
      "The unique physical device identifier (UUID) bound to this user session",
    example: "f3910c23-7fa3-43ef-b3be-ef968ef7328d",
  })
  @IsString()
  deviceIdentifier: string;

  @ApiProperty({
    description: "The exact date for this step count in YYYY-MM-DD format",
    example: "2026-05-20",
  })
  @IsDateString()
  date: string;

  @ApiProperty({
    description: "The total cumulative step count recorded for the date",
    example: 8420,
    minimum: 0,
  })
  @IsNumber()
  @Min(0)
  stepCount: number;

  @ApiPropertyOptional({
    description: "Active activity minutes recorded on the day",
    example: 45,
    minimum: 0,
  })
  @IsOptional()
  @IsNumber()
  @Min(0)
  activeMinutes?: number;

  @ApiPropertyOptional({
    description: "Source origin of the sync data",
    example: "google_fit",
    enum: ["manual", "google_fit", "apple_health"],
  })
  @IsOptional()
  @IsString()
  source?: string;

  @ApiPropertyOptional({
    description:
      "Cryptographic unique nonce token to prevent sync replay attacks",
    example: "550e8400-e29b-41d4-a716-446655440000",
  })
  @IsOptional()
  @IsString()
  nonce?: string;

  @ApiPropertyOptional({
    description: "Epoch client timestamp milliseconds for drift checks",
    example: 1779282361000,
  })
  @IsOptional()
  @IsNumber()
  timestamp?: number;

  @ApiPropertyOptional({
    description: "Device security attestation parameters",
    type: () => DeviceIntegrityDto,
  })
  @IsOptional()
  @IsObject()
  @ValidateNested()
  @Type(() => DeviceIntegrityDto)
  integrity?: DeviceIntegrityDto;
}
