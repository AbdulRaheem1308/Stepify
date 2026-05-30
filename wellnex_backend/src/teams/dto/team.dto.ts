import {
  IsString,
  IsNotEmpty,
  IsOptional,
  IsBoolean,
  IsNumber,
  Min,
  Max,
} from "class-validator";
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";

export class CreateTeamDto {
  @ApiProperty({ example: "Fitness Fanatics", description: "Name of the team" })
  @IsString()
  @IsNotEmpty()
  name: string;

  @ApiPropertyOptional({
    example: "A group for fitness enthusiasts",
    description: "Description of the team",
  })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiPropertyOptional({
    example: 10,
    description: "Maximum members allowed",
    minimum: 2,
    maximum: 50,
  })
  @IsNumber()
  @Min(2)
  @Max(50)
  @IsOptional()
  maxMembers?: number;

  @ApiPropertyOptional({
    example: true,
    description: "Whether the team is publicly discoverable",
  })
  @IsBoolean()
  @IsOptional()
  isPublic?: boolean;
}

export class JoinTeamDto {
  @ApiPropertyOptional({
    example: "xyz-123",
    description: "Invite code for private teams",
  })
  @IsString()
  @IsOptional()
  inviteCode?: string;
}

export class InitiateBattleDto {
  @ApiProperty({ example: "team-456", description: "ID of the opponent team" })
  @IsString()
  @IsNotEmpty()
  opponentTeamId: string;
}
