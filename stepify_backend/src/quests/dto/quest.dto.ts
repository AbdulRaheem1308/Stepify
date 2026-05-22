import { IsString, IsOptional } from "class-validator";
import { ApiPropertyOptional } from "@nestjs/swagger";

export class JoinQuestDto {
  @ApiPropertyOptional({
    example: "user-123",
    description:
      "Optional user ID for joining on behalf of someone (admins only). Defaults to current user.",
  })
  @IsString()
  @IsOptional()
  userId?: string;
}
