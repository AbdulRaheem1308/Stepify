import { Controller, Post, Body, UseGuards, Get } from "@nestjs/common";
import { ActivitiesService } from "./activities.service";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { CurrentUser } from "../auth/decorators/current-user.decorator";
import { IsString, IsNumber, Min, IsOptional } from "class-validator";

export class LogActivityDto {
  @IsString()
  type: string;

  @IsNumber()
  @Min(1)
  durationMinutes: number;

  @IsOptional()
  @IsNumber()
  distanceKm?: number;

  @IsNumber()
  @Min(0)
  caloriesBurned: number;

  @IsString()
  startTime: string;

  @IsOptional()
  @IsString()
  source?: string;
}

@Controller("activities")
@UseGuards(JwtAuthGuard)
export class ActivitiesController {
  constructor(private readonly activitiesService: ActivitiesService) {}

  @Post()
  async logActivity(@CurrentUser() user: any, @Body() dto: LogActivityDto) {
    return this.activitiesService.logActivity(user.id, dto);
  }

  @Get()
  async getRecentActivities(@CurrentUser() user: any) {
    return this.activitiesService.getRecentActivities(user.id);
  }
}
