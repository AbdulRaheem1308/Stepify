import { Controller, Get, Post, Body, Query, UseGuards } from "@nestjs/common";
import { AdsService } from "./ads.service";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { CurrentUser } from "../auth/decorators/current-user.decorator";
import { ClaimAdRewardDto } from "./dto/ads.dto";
import { GetAdHistoryDto } from "./dto/get-ad-history.dto";
import {
  ApiTags,
  ApiBearerAuth,
  ApiOperation,
  ApiResponse,
} from "@nestjs/swagger";

@ApiTags("Ads")
@ApiBearerAuth()
@Controller("ads")
@UseGuards(JwtAuthGuard)
export class AdsController {
  constructor(private readonly adsService: AdsService) {}

  @Get("can-watch")
  @ApiOperation({
    summary: "Check if the user can currently watch a rewarded ad",
  })
  @ApiResponse({
    status: 200,
    description: "Returns ad availability and cooldown details",
  })
  async canWatchAd(@CurrentUser() user: any) {
    return this.adsService.checkCanWatchAd(user.id);
  }

  @Post("claim")
  @ApiOperation({ summary: "Claim a reward for watching an ad" })
  @ApiResponse({ status: 201, description: "Reward claimed successfully" })
  @ApiResponse({
    status: 400,
    description: "Cooldown active or daily limit reached",
  })
  async claimReward(@CurrentUser() user: any, @Body() dto: ClaimAdRewardDto) {
    return this.adsService.claimAdReward(user.id, dto.adType, dto.adUnitId);
  }

  @Get("history")
  @ApiOperation({ summary: "Get the user's ad watch history" })
  @ApiResponse({
    status: 200,
    description: "Returns paginated ad history and summary",
  })
  async getHistory(@CurrentUser() user: any, @Query() query: GetAdHistoryDto) {
    return this.adsService.getAdHistory(user.id, query.page, query.limit);
  }
}
