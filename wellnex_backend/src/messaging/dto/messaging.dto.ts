import { IsString, IsNotEmpty, IsOptional } from "class-validator";
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";

export class StartConversationDto {
  @ApiPropertyOptional({
    example: "user-uuid-1234",
    description:
      "ID of the user starting the conversation (defaults to current user)",
  })
  @IsString()
  @IsOptional()
  userId?: string;

  @ApiProperty({
    example: "user-uuid-5678",
    description: "ID of the other user",
  })
  @IsString()
  @IsNotEmpty()
  otherUserId: string;
}

export class SendMessageDto {
  @ApiProperty({
    example: "conv-uuid-1234",
    description: "ID of the conversation",
  })
  @IsString()
  @IsNotEmpty()
  conversationId: string;

  @ApiPropertyOptional({
    example: "user-uuid-1234",
    description: "ID of the sender (defaults to current user)",
  })
  @IsString()
  @IsOptional()
  senderId?: string;

  @ApiProperty({
    example: "Hello, how are you?",
    description: "Content of the message",
  })
  @IsString()
  @IsNotEmpty()
  content: string;
}
