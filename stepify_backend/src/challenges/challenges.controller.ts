import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
  UseGuards,
  Req,
} from "@nestjs/common";
import { Request } from "express";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { ChallengesService } from "./challenges.service";
import {
  JoinChallengeDto,
  UpdateChallengeProgressDto,
  ChallengeStatus,
} from "./dto/challenge.dto";

// Extend Express Request to include user property from JWT
interface AuthenticatedRequest extends Request {
  user: { id: string; [key: string]: any };
}

@Controller("challenges")
@UseGuards(JwtAuthGuard)
export class ChallengesController {
  constructor(private readonly challengesService: ChallengesService) {}

  /**
   * GET /challenges - Get all available challenges
   */
  @Get()
  async findAll() {
    return this.challengesService.findAll();
  }

  /**
   * GET /challenges/new - Get new challenges (not joined by user)
   */
  @Get("new")
  async findNew(@Req() req: AuthenticatedRequest) {
    return this.challengesService.findNewChallenges(req.user.id);
  }

  /**
   * GET /challenges/my - Get user's challenges
   */
  @Get("my")
  async findMy(
    @Req() req: AuthenticatedRequest,
    @Query("status") status?: ChallengeStatus,
  ) {
    return this.challengesService.findUserChallenges(req.user.id, status);
  }

  /**
   * GET /challenges/ongoing - Get user's ongoing challenges
   */
  @Get("ongoing")
  async findOngoing(@Req() req: AuthenticatedRequest) {
    return this.challengesService.findUserChallenges(
      req.user.id,
      ChallengeStatus.ONGOING,
    );
  }

  /**
   * GET /challenges/completed - Get user's completed challenges
   */
  @Get("completed")
  async findCompleted(@Req() req: AuthenticatedRequest) {
    return this.challengesService.findUserChallenges(
      req.user.id,
      ChallengeStatus.COMPLETED,
    );
  }

  /**
   * GET /challenges/:id - Get a single challenge
   */
  @Get(":id")
  async findOne(@Param("id") id: string) {
    return this.challengesService.findOne(id);
  }

  /**
   * POST /challenges/join - Join a challenge
   */
  @Post("join")
  async join(@Req() req: AuthenticatedRequest, @Body() dto: JoinChallengeDto) {
    return this.challengesService.join(req.user.id, dto.challengeId);
  }

  /**
   * POST /challenges/progress - Update challenge progress
   */
  @Post("progress")
  async updateProgress(
    @Req() req: AuthenticatedRequest,
    @Body() dto: UpdateChallengeProgressDto,
  ) {
    return this.challengesService.updateProgress(
      req.user.id,
      dto.challengeId,
      dto.stepsToAdd,
    );
  }

  /**
   * POST /challenges/seed - Seed demo challenges (dev only)
   */
  @Post("seed")
  async seed() {
    return this.challengesService.seedDemoChallenges();
  }
}
