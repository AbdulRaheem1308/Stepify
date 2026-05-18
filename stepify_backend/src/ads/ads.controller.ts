import { Controller, Get, Post, Body, Query, UseGuards } from '@nestjs/common';
import { AdsService } from './ads.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { ClaimAdRewardDto } from './dto/ads.dto';

@Controller('ads')
@UseGuards(JwtAuthGuard)
export class AdsController {
    constructor(private adsService: AdsService) { }

    /**
     * Check if user can watch a rewarded ad
     * GET /api/v1/ads/can-watch
     */
    @Get('can-watch')
    async canWatchAd(@CurrentUser() user: any) {
        return this.adsService.checkCanWatchAd(user.id);
    }

    /**
     * Claim reward for watching an ad
     * POST /api/v1/ads/claim
     */
    @Post('claim')
    async claimReward(@CurrentUser() user: any, @Body() dto: ClaimAdRewardDto) {
        return this.adsService.claimAdReward(user.id, dto.adType, dto.adUnitId);
    }

    /**
     * Get ad watch history
     * GET /api/v1/ads/history
     */
    @Get('history')
    async getHistory(
        @CurrentUser() user: any,
        @Query('page') page: number = 1,
        @Query('limit') limit: number = 20,
    ) {
        return this.adsService.getAdHistory(user.id, page, limit);
    }
}
