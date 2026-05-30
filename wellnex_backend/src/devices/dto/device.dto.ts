import { IsString, IsNotEmpty, IsOptional, IsEnum } from "class-validator";
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { DeviceType } from "@prisma/client";

export class AddDeviceDto {
  @ApiProperty({
    example: "Apple Watch Series 9",
    description: "Name of the device",
  })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiProperty({
    example: "SMARTWATCH",
    description: "Type of device",
    enum: DeviceType,
  })
  @IsEnum(DeviceType)
  @IsNotEmpty()
  type: DeviceType;

  @ApiPropertyOptional({
    example: "serial-12345",
    description: "Unique device identifier",
  })
  @IsString()
  @IsOptional()
  identifier?: string;
}
