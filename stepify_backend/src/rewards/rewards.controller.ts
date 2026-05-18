import { Controller, Get, Post, Query, Body, Param, UseGuards } from '@nestjs/common';
import { RewardsService } from './rewards.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@Controller('rewards')
@UseGuards(JwtAuthGuard)
export class RewardsController {
    constructor(private rewardsService: RewardsService) { }

    /**
     * Get wallet balance
     * GET /api/v1/rewards/wallet
     */
    @Get('wallet')
    async getWallet(@CurrentUser() user: any) {
        return this.rewardsService.getWallet(user.id);
    }

    /**
     * Get transaction history
     * GET /api/v1/rewards/transactions
     */
    @Get('transactions')
    async getTransactions(
        @CurrentUser() user: any,
        @Query('page') page: number = 1,
        @Query('limit') limit: number = 20,
    ) {
        return this.rewardsService.getTransactions(user.id, page, limit);
    }

    /**
     * Get streak info
     * GET /api/v1/rewards/streak
     */
    @Get('streak')
    async getStreak(@CurrentUser() user: any) {
        return this.rewardsService.getStreak(user.id);
    }

    /**
     * Get achievements
     * GET /api/v1/rewards/achievements
     */
    @Get('achievements')
    async getAchievements(@CurrentUser() user: any) {
        return this.rewardsService.getAchievements(user.id);
    }

    /**
     * Get all levels
     * GET /api/v1/rewards/levels (also aliased as /gamification/levels)
     */
    @Get('levels')
    async getLevels() {
        return this.rewardsService.getLevels();
    }

    // ==========================================
    // REWARDS CATALOG & REDEMPTION
    // ==========================================

    /**
     * Get rewards catalog
     * GET /api/v1/rewards/catalog
     */
    @Get('catalog')
    async getCatalog(
        @CurrentUser() user: any,
        @Query('category') category?: string,
    ) {
        return this.rewardsService.getRewardsCatalog(user.id, category);
    }

    /**
     * Get single reward details
     * GET /api/v1/rewards/catalog/:id
     */
    @Get('catalog/:id')
    async getRewardDetails(@Param('id') id: string, @CurrentUser() user: any) {
        return this.rewardsService.getRewardDetails(id, user.id);
    }

    /**
     * Redeem a reward
     * POST /api/v1/rewards/redeem
     */
    @Post('redeem')
    async redeemReward(
        @CurrentUser() user: any,
        @Body('rewardId') rewardId: string,
    ) {
        return this.rewardsService.redeemReward(user.id, rewardId);
    }

    /**
     * Get user's redeemed rewards (My Offers)
     * GET /api/v1/rewards/my-offers
     */
    @Get('my-offers')
    async getMyOffers(
        @CurrentUser() user: any,
        @Query('status') status?: string,
    ) {
        return this.rewardsService.getMyOffers(user.id, status);
    }

    /**
     * Seed demo rewards (dev only)
     * POST /api/v1/rewards/seed
     */
    @Post('seed')
    async seedRewards() {
        return this.rewardsService.seedDemoRewards();
    }
}
