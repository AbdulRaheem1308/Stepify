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
import { CreateCompanyDto, JoinCompanyDto } from "./dto/company.dto";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from "@nestjs/swagger";

@ApiTags("Companies")
@ApiBearerAuth()
@Controller("companies")
@UseGuards(JwtAuthGuard)
export class CompaniesController {
  constructor(private readonly companiesService: CompaniesService) {}

  @Post()
  @ApiOperation({ summary: "Create a new wellness corporate group" })
  @ApiResponse({ status: 201, description: "Company created successfully" })
  async create(@Body() body: CreateCompanyDto) {
    return this.companiesService.createCompany(body);
  }

  @Get()
  @ApiOperation({ summary: "Get all companies" })
  @ApiResponse({ status: 200, description: "Returns list of companies" })
  async findAll() {
    return this.companiesService.findAll();
  }

  @Post(":joinCode/join")
  @ApiOperation({ summary: "Join a company using an invite code" })
  @ApiResponse({ status: 201, description: "Successfully joined company" })
  @ApiResponse({ status: 404, description: "Invalid invite code" })
  async joinCompany(
    @Param("joinCode") joinCode: string,
    @Body() body: JoinCompanyDto,
    @CurrentUser() user: any,
  ) {
    // IDOR Prevention: Extract authentic userId from JWT. If body parameter provided, validate it matches.
    const resolvedUserId = body.userId || user.id;
    if (body.userId && body.userId !== user.id) {
      throw new ForbiddenException(
        "Cannot join a company on behalf of another user",
      );
    }
    return this.companiesService.joinCompany(joinCode, resolvedUserId);
  }

  @Get(":id/leaderboard")
  @ApiOperation({ summary: "Get company leaderboard" })
  @ApiResponse({ status: 200, description: "Returns top members of company" })
  async getLeaderboard(@Param("id") id: string) {
    return this.companiesService.getCompanyLeaderboard(id);
  }

  @Get("my-company/:userId")
  @ApiOperation({ summary: "Get user's company details" })
  @ApiResponse({
    status: 200,
    description: "Returns company and department info",
  })
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
