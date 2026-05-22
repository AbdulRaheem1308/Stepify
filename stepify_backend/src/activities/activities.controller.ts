import { Controller, Post, Body, UseGuards, Get, Query } from "@nestjs/common";
import { ActivitiesService } from "./activities.service";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { CurrentUser } from "../auth/decorators/current-user.decorator";
import { LogActivityDto } from "./dto/log-activity.dto";
import { GetActivitiesDto } from "./dto/get-activities.dto";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from "@nestjs/swagger";

@ApiTags("Activities")
@ApiBearerAuth()
@Controller("activities")
@UseGuards(JwtAuthGuard)
export class ActivitiesController {
  constructor(private readonly activitiesService: ActivitiesService) {}

  @Post()
  @ApiOperation({ summary: "Log a new physical activity" })
  @ApiResponse({
    status: 201,
    description:
      "The activity has been successfully logged and points awarded.",
  })
  @ApiResponse({
    status: 400,
    description: "Validation error or physically impossible data submitted.",
  })
  @ApiResponse({
    status: 409,
    description: "Duplicate activity submission.",
  })
  async logActivity(@CurrentUser() user: any, @Body() dto: LogActivityDto) {
    return this.activitiesService.logActivity(user.id, dto);
  }

  @Get()
  @ApiOperation({ summary: "Get a paginated list of recent activities" })
  @ApiResponse({
    status: 200,
    description: "Returns the paginated activities list.",
  })
  async getRecentActivities(
    @CurrentUser() user: any,
    @Query() query: GetActivitiesDto,
  ) {
    return this.activitiesService.getRecentActivities(user.id, query);
  }
}
