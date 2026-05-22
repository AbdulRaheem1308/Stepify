import { Controller, Post, Get, Body, Query, UseGuards } from "@nestjs/common";
import { StepsService } from "./steps.service";
import { SyncStepsDto } from "./dto/steps.dto";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { CurrentUser } from "../auth/decorators/current-user.decorator";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiQuery,
} from "@nestjs/swagger";

@ApiTags("Steps")
@ApiBearerAuth()
@Controller("steps")
@UseGuards(JwtAuthGuard)
export class StepsController {
  constructor(private stepsService: StepsService) {}

  /**
   * Sync step data
   * POST /api/v1/steps/sync
   */
  @Post("sync")
  @ApiOperation({ summary: "Sync step data from device" })
  @ApiResponse({ status: 201, description: "Steps synced successfully" })
  async syncSteps(@CurrentUser() user: any, @Body() dto: SyncStepsDto) {
    return this.stepsService.syncSteps(user.id, dto);
  }

  /**
   * Get today's steps
   * GET /api/v1/steps/today
   */
  @Get("today")
  @ApiOperation({ summary: "Get today's steps for the current user" })
  @ApiResponse({ status: 200, description: "Returns today's steps" })
  async getTodaySteps(@CurrentUser() user: any) {
    return this.stepsService.getTodaySteps(user.id);
  }

  /**
   * Get step history
   * GET /api/v1/steps/history
   */
  @Get("history")
  @ApiOperation({ summary: "Get user's step history (paginated)" })
  @ApiQuery({ name: "page", required: false, type: String })
  @ApiQuery({ name: "limit", required: false, type: String })
  @ApiResponse({ status: 200, description: "Returns step history" })
  async getHistory(
    @CurrentUser() user: any,
    @Query("page") page?: string,
    @Query("limit") limit?: string,
  ) {
    // Parse query params to integers with defaults
    const pageNum = Number.parseInt(page || "1", 10) || 1;
    const limitNum = Number.parseInt(limit || "30", 10) || 30;
    return this.stepsService.getHistory(user.id, pageNum, limitNum);
  }

  /**
   * Get weekly summary
   * GET /api/v1/steps/weekly
   */
  @Get("weekly")
  @ApiOperation({ summary: "Get weekly steps summary for the current user" })
  @ApiResponse({ status: 200, description: "Returns weekly summary" })
  async getWeeklySummary(@CurrentUser() user: any) {
    return this.stepsService.getWeeklySummary(user.id);
  }

  /**
   * Get monthly summary
   * GET /api/v1/steps/monthly
   */
  @Get("monthly")
  @ApiOperation({ summary: "Get monthly steps summary for the current user" })
  @ApiQuery({ name: "year", required: false, type: Number })
  @ApiQuery({ name: "month", required: false, type: Number })
  @ApiResponse({ status: 200, description: "Returns monthly summary" })
  async getMonthlySummary(
    @CurrentUser() user: any,
    @Query("year") year?: number,
    @Query("month") month?: number,
  ) {
    return this.stepsService.getMonthlySummary(user.id, year, month);
  }
}
