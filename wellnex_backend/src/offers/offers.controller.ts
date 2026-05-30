import {
  Controller,
  Get,
  Post,
  Param,
  Query,
  UseGuards,
  Body,
} from "@nestjs/common";
import { OffersService } from "./offers.service";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { CurrentUser } from "../auth/decorators/current-user.decorator";
import { CreateOfferDto } from "./dto/offer.dto";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiQuery,
} from "@nestjs/swagger";

@ApiTags("Offers")
@ApiBearerAuth()
@Controller("offers")
@UseGuards(JwtAuthGuard)
export class OffersController {
  constructor(private readonly offersService: OffersService) {}

  @Get()
  @ApiOperation({ summary: "List all active offers" })
  @ApiResponse({ status: 200, description: "Returns active offers" })
  async findAll() {
    return this.offersService.findAllActive();
  }

  @Get("my")
  @ApiOperation({ summary: "Get user's offers history" })
  @ApiQuery({
    name: "status",
    required: false,
    description: "Filter by status",
  })
  @ApiResponse({ status: 200, description: "Returns user offers" })
  async getMyOffers(
    @CurrentUser() user: any,
    @Query("status") status?: string,
  ) {
    return this.offersService.getUserOffers(user.id, status);
  }

  @Post(":id/start")
  @ApiOperation({ summary: "Start tracking an offer" })
  @ApiResponse({ status: 201, description: "Offer started" })
  async startOffer(@CurrentUser() user: any, @Param("id") offerId: string) {
    return this.offersService.startOffer(user.id, offerId);
  }

  @Post(":id/complete")
  @ApiOperation({ summary: "Complete an offer and claim reward" })
  @ApiResponse({ status: 201, description: "Reward claimed" })
  async completeOffer(@CurrentUser() user: any, @Param("id") offerId: string) {
    return this.offersService.completeOffer(user.id, offerId);
  }

  @Post()
  @ApiOperation({ summary: "Create a new offer (Admin)" })
  @ApiResponse({ status: 201, description: "Offer created" })
  async createOffer(@Body() dto: CreateOfferDto) {
    return this.offersService.createOffer(dto);
  }
}
