import { IsOptional, IsInt, Min, Max } from "class-validator";
import { ApiPropertyOptional } from "@nestjs/swagger";
import { Type } from "class-transformer";
import { ACTIVITIES_CONSTANTS } from "../constants/activities.constants";

export class GetActivitiesDto {
  @ApiPropertyOptional({
    description: "Page number for pagination",
    minimum: 1,
    default: ACTIVITIES_CONSTANTS.DEFAULT_PAGE,
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = ACTIVITIES_CONSTANTS.DEFAULT_PAGE;

  @ApiPropertyOptional({
    description: "Number of items per page",
    minimum: 1,
    maximum: 100,
    default: ACTIVITIES_CONSTANTS.DEFAULT_LIMIT,
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = ACTIVITIES_CONSTANTS.DEFAULT_LIMIT;
}
