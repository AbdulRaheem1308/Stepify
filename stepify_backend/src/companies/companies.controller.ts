import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  UseGuards,
  ForbiddenException,
} from "@nestjs/common";
import { CompaniesService } from "./companies.service";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { CurrentUser } from "../auth/decorators/current-user.decorator";

@Controller("companies")
@UseGuards(JwtAuthGuard)
export class CompaniesController {
  constructor(private readonly companiesService: CompaniesService) {}

  @Post()
  async create(@Body() body: any) {
    // Create a new wellness corporate group
    return this.companiesService.createCompany(body);
  }

  @Get()
  async findAll() {
    return this.companiesService.findAll();
  }

  @Post(":joinCode/join")
  async joinCompany(
    @Param("joinCode") joinCode: string,
    @Body("userId") bodyUserId: string,
    @CurrentUser() user: any,
  ) {
    // IDOR Prevention: Extract authentic userId from JWT. If body parameter provided, validate it matches.
    const resolvedUserId = bodyUserId || user.id;
    if (bodyUserId && bodyUserId !== user.id) {
      throw new ForbiddenException(
        "Cannot join a company on behalf of another user",
      );
    }
    return this.companiesService.joinCompany(joinCode, resolvedUserId);
  }

  @Get(":id/leaderboard")
  async getLeaderboard(@Param("id") id: string) {
    return this.companiesService.getCompanyLeaderboard(id);
  }

  @Get("my-company/:userId")
  async getMyCompany(
    @Param("userId") userId: string,
    @CurrentUser() user: any,
  ) {
    // IDOR & Functionality Fix: Support 'me' alias correctly and prevent unauthorized inspection of other users
    const resolvedUserId = userId === "me" ? user.id : userId;
    if (resolvedUserId && resolvedUserId !== user.id) {
      throw new ForbiddenException(
        "Cannot query company details for another user",
      );
    }
    return this.companiesService.getUserCompany(resolvedUserId);
  }
}
