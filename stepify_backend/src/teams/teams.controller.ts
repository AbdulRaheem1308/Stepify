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

interface AuthenticatedRequest extends ExpressRequest {
  user: { id: string; [key: string]: any };
}

@Controller("teams")
@UseGuards(JwtAuthGuard)
export class TeamsController {
  constructor(private teamsService: TeamsService) {}

  // GET /teams/my-teams - Get user's teams
  @Get("my-teams")
  async getMyTeams(@Request() req: AuthenticatedRequest) {
    return this.teamsService.getMyTeams(req.user.id);
  }

  // GET /teams/public - Get public teams to join
  @Get("public")
  async getPublicTeams(@Request() req: AuthenticatedRequest) {
    return this.teamsService.getPublicTeams(req.user.id);
  }

  // GET /teams/leaderboard - Get team leaderboard
  @Get("leaderboard")
  async getLeaderboard() {
    return this.teamsService.getTeamLeaderboard();
  }

  // GET /teams/:id - Get team details
  @Get(":id")
  async getTeamDetails(
    @Param("id") id: string,
    @Request() req: AuthenticatedRequest,
  ) {
    return this.teamsService.getTeamDetails(id, req.user.id);
  }

  // GET /teams/:id/challenges - Get team challenges
  @Get(":id/challenges")
  async getTeamChallenges(@Param("id") id: string) {
    return this.teamsService.getTeamChallenges(id);
  }

  // POST /teams - Create a new team
  @Post()
  async createTeam(
    @Request() req: AuthenticatedRequest,
    @Body()
    body: {
      name: string;
      description?: string;
      maxMembers?: number;
      isPublic?: boolean;
    },
  ) {
    return this.teamsService.createTeam(req.user.id, body);
  }

  // POST /teams/:id/join - Join a team
  @Post(":id/join")
  async joinTeam(
    @Param("id") id: string,
    @Request() req: AuthenticatedRequest,
    @Body() body: { inviteCode?: string },
  ) {
    return this.teamsService.joinTeam(id, req.user.id, body.inviteCode);
  }

  // POST /teams/:id/leave - Leave a team
  @Post(":id/leave")
  async leaveTeam(
    @Param("id") id: string,
    @Request() req: AuthenticatedRequest,
  ) {
    return this.teamsService.leaveTeam(id, req.user.id);
  }

  // POST /teams/:id/battle - Initiate a Team Battle
  @Post(":id/battle")
  async initiateBattle(
    @Param("id") challengerTeamId: string,
    @Body() body: { opponentTeamId: string },
    @Request() req: AuthenticatedRequest,
  ) {
    return this.teamsService.initiateBattle(
      challengerTeamId,
      body.opponentTeamId,
      req.user.id,
    );
  }

  // DELETE /teams/:id - Delete a team (Captain only)
  @Delete(":id")
  async deleteTeam(
    @Param("id") id: string,
    @Request() req: AuthenticatedRequest,
  ) {
    return this.teamsService.deleteTeam(id, req.user.id);
  }
}
