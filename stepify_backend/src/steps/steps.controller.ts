import { Controller, Post, Get, Body, Query, UseGuards } from "@nestjs/common";
import { StepsService } from "./steps.service";
import { SyncStepsDto } from "./dto/steps.dto";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { CurrentUser } from "../auth/decorators/current-user.decorator";

@Controller("steps")
@UseGuards(JwtAuthGuard)
export class StepsController {
  constructor(private stepsService: StepsService) {}

  /**
   * Sync step data
   * POST /api/v1/steps/sync
   */
  @Post("sync")
  async syncSteps(@CurrentUser() user: any, @Body() dto: SyncStepsDto) {
    return this.stepsService.syncSteps(user.id, dto);
  }

  /**
   * Get today's steps
   * GET /api/v1/steps/today
   */
  @Get("today")
  async getTodaySteps(@CurrentUser() user: any) {
    return this.stepsService.getTodaySteps(user.id);
  }

  /**
   * Get step history
   * GET /api/v1/steps/history
   */
  @Get("history")
  async getHistory(
    @CurrentUser() user: any,
    @Query("page") page?: string,
    @Query("limit") limit?: string,
  ) {
    // Parse query params to integers with defaults
    const pageNum = parseInt(page || "1", 10) || 1;
    const limitNum = parseInt(limit || "30", 10) || 30;
    return this.stepsService.getHistory(user.id, pageNum, limitNum);
  }

  /**
   * Get weekly summary
   * GET /api/v1/steps/weekly
   */
  @Get("weekly")
  async getWeeklySummary(@CurrentUser() user: any) {
    return this.stepsService.getWeeklySummary(user.id);
  }

  /**
   * Get monthly summary
   * GET /api/v1/steps/monthly
   */
  @Get("monthly")
  async getMonthlySummary(
    @CurrentUser() user: any,
    @Query("year") year?: number,
    @Query("month") month?: number,
  ) {
    return this.stepsService.getMonthlySummary(user.id, year, month);
  }
}
