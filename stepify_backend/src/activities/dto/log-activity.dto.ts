import {
  IsEnum,
  IsNumber,
  Min,
  IsOptional,
  IsString,
  IsISO8601,
  IsIn,
} from "class-validator";
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { ActivityType } from "../enums/activity-type.enum";
import {
  ACTIVITIES_CONSTANTS,
  VALID_ACTIVITY_SOURCES,
} from "../constants/activities.constants";

export class LogActivityDto {
  @ApiProperty({
    description: "The type of activity being logged",
    enum: ActivityType,
    example: ActivityType.RUNNING,
  })
  @IsEnum(ActivityType)
  type: ActivityType;

  @ApiProperty({
    description: "Duration of the activity in minutes",
    minimum: 1,
    maximum: ACTIVITIES_CONSTANTS.MAX_DURATION_MINUTES,
    example: 45,
  })
  @IsNumber()
  @Min(1)
  durationMinutes: number;

  @ApiPropertyOptional({
    description: "Distance covered in kilometers (if applicable)",
    minimum: 0,
    example: 5.2,
  })
  @IsOptional()
  @IsNumber()
  @Min(0)
  distanceKm?: number;

  @ApiProperty({
    description: "Total calories burned during the activity",
    minimum: 0,
    example: 320,
  })
  @IsNumber()
  @Min(0)
  caloriesBurned: number;

  @ApiProperty({
    description: "Start time of the activity in ISO 8601 format",
    example: "2024-05-22T10:00:00Z",
  })
  @IsISO8601()
  startTime: string;

  @ApiPropertyOptional({
    description: "Source of the activity data",
    example: "manual",
    default: "manual",
  })
  @IsOptional()
  @IsString()
  @IsIn(VALID_ACTIVITY_SOURCES)
  source?: string;
}
