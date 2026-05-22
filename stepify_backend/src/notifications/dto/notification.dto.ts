import { IsString, IsNotEmpty } from "class-validator";
import { ApiProperty } from "@nestjs/swagger";

export class RegisterFcmTokenDto {
  @ApiProperty({ example: "fcm-token-123", description: "FCM device token" })
  @IsString()
  @IsNotEmpty()
  token: string;
}
