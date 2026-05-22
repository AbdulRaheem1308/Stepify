import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  UseGuards,
  Request,
} from "@nestjs/common";
import { Request as ExpressRequest } from "express";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { TeamsService } from "./teams.service";
import { CreateTeamDto, JoinTeamDto, InitiateBattleDto } from "./dto/team.dto";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiParam,
} from "@nestjs/swagger";

interface AuthenticatedRequest extends ExpressRequest {
  user: { id: string; [key: string]: any };
}

@ApiTags("Teams")
@ApiBearerAuth()
@Controller("teams")
@UseGuards(JwtAuthGuard)
export class TeamsController {
  constructor(private readonly teamsService: TeamsService) {}

  /**
   * Get user's teams
   */
  @Get("my-teams")
  @ApiOperation({ summary: "Get teams the current user is a member of" })
  @ApiResponse({ status: 200, description: "Returns user's teams" })
  async getMyTeams(@Request() req: AuthenticatedRequest) {
    return this.teamsService.getMyTeams(req.user.id);
  }

  /**
   * Get public teams to join
   */
  @Get("public")
  @ApiOperation({ summary: "Get discoverable public teams" })
  @ApiResponse({ status: 200, description: "Returns list of public teams" })
  async getPublicTeams(@Request() req: AuthenticatedRequest) {
    return this.teamsService.getPublicTeams(req.user.id);
  }

  /**
   * Get team leaderboard
   */
  @Get("leaderboard")
  @ApiOperation({ summary: "Get global team leaderboard" })
  @ApiResponse({
    status: 200,
    description: "Returns team rankings based on weekly steps",
  })
  async getLeaderboard() {
    return this.teamsService.getTeamLeaderboard();
  }

  /**
   * Get team details
   */
  @Get(":id")
  @ApiOperation({ summary: "Get detailed information for a specific team" })
  @ApiParam({ name: "id", description: "Team ID" })
  @ApiResponse({ status: 200, description: "Returns team details" })
  async getTeamDetails(
    @Param("id") id: string,
    @Request() req: AuthenticatedRequest,
  ) {
    return this.teamsService.getTeamDetails(id, req.user.id);
  }

  /**
   * Get team challenges
   */
  @Get(":id/challenges")
  @ApiOperation({ summary: "Get challenges associated with a team" })
  @ApiParam({ name: "id", description: "Team ID" })
  @ApiResponse({ status: 200, description: "Returns team challenges" })
  async getTeamChallenges(@Param("id") id: string) {
    return this.teamsService.getTeamChallenges(id);
  }

  /**
   * Create a new team
   */
  @Post()
  @ApiOperation({ summary: "Create a new team" })
  @ApiResponse({ status: 201, description: "Team created successfully" })
  async createTeam(
    @Request() req: AuthenticatedRequest,
    @Body() dto: CreateTeamDto,
  ) {
    return this.teamsService.createTeam(req.user.id, dto);
  }

  /**
   * Join a team
   */
  @Post(":id/join")
  @ApiOperation({ summary: "Join an existing team" })
  @ApiParam({ name: "id", description: "Team ID" })
  @ApiResponse({ status: 201, description: "Successfully joined the team" })
  async joinTeam(
    @Param("id") id: string,
    @Request() req: AuthenticatedRequest,
    @Body() dto: JoinTeamDto,
  ) {
    return this.teamsService.joinTeam(id, req.user.id, dto.inviteCode);
  }

  /**
   * Leave a team
   */
  @Post(":id/leave")
  @ApiOperation({ summary: "Leave a team" })
  @ApiParam({ name: "id", description: "Team ID" })
  @ApiResponse({ status: 201, description: "Successfully left the team" })
  async leaveTeam(
    @Param("id") id: string,
    @Request() req: AuthenticatedRequest,
  ) {
    return this.teamsService.leaveTeam(id, req.user.id);
  }

  /**
   * Initiate a Team Battle
   */
  @Post(":id/battle")
  @ApiOperation({ summary: "Initiate a battle against another team" })
  @ApiParam({ name: "id", description: "Challenger Team ID" })
  @ApiResponse({ status: 201, description: "Battle initiated successfully" })
  async initiateBattle(
    @Param("id") challengerTeamId: string,
    @Body() dto: InitiateBattleDto,
    @Request() req: AuthenticatedRequest,
  ) {
    return this.teamsService.initiateBattle(
      challengerTeamId,
      dto.opponentTeamId,
      req.user.id,
    );
  }

  /**
   * Delete a team (Captain only)
   */
  @Delete(":id")
  @ApiOperation({ summary: "Delete a team (requires Captain role)" })
  @ApiParam({ name: "id", description: "Team ID" })
  @ApiResponse({ status: 200, description: "Team deleted successfully" })
  async deleteTeam(
    @Param("id") id: string,
    @Request() req: AuthenticatedRequest,
  ) {
    return this.teamsService.deleteTeam(id, req.user.id);
  }
}
