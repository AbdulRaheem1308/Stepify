import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsEmail,
  IsPhoneNumber,
} from "class-validator";
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";

export class FriendRequestDto {
  @ApiProperty({
    example: "user-uuid-1234",
    description: "ID of the friend to request",
  })
  @IsString()
  @IsNotEmpty()
  friendId: string;
}

export class AcceptRequestDto {
  @ApiProperty({
    example: "user-uuid-1234",
    description: "ID of the user who sent the request",
  })
  @IsString()
  @IsNotEmpty()
  requesterId: string;
}

export class CreateInvitationDto {
  @ApiPropertyOptional({
    example: "friend@example.com",
    description: "Email of the invitee",
  })
  @IsOptional()
  @IsEmail()
  email?: string;

  @ApiPropertyOptional({
    example: "+1234567890",
    description: "Phone number of the invitee",
  })
  @IsOptional()
  @IsPhoneNumber()
  phone?: string;
}
