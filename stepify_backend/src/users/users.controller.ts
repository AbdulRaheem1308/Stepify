import { Controller, Get, Put, Post, Body, Query, UseGuards } from '@nestjs/common';
import { UsersService } from './users.service';
import { UpdateUserDto } from './dto/user.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@Controller('users')
@UseGuards(JwtAuthGuard)
export class UsersController {
    constructor(private usersService: UsersService) { }

    /**
     * Get available avatars
     * GET /api/v1/users/avatars
     */
    @Get('avatars')
    async getAvatars() {
        return this.usersService.getAvatars();
    }

    /**
     * Get current user profile
     * GET /api/v1/users/me
     */
    @Get('me')
    async getProfile(@CurrentUser() user: any) {
        return this.usersService.findById(user.id);
    }

    /**
     * Update user profile
     * PUT /api/v1/users/me
     */
    @Put('me')
    async updateProfile(@CurrentUser() user: any, @Body() dto: UpdateUserDto) {
        return this.usersService.update(user.id, dto);
    }

    /**
     * Get user statistics
     * GET /api/v1/users/me/stats
     */
    @Get('me/stats')
    async getStats(@CurrentUser() user: any) {
        return this.usersService.getUserStats(user.id);
    }

    /**
     * Get referral leaderboard (Screen 18)
     * GET /api/v1/users/referral-leaderboard
     */
    @Get('referral-leaderboard')
    async getReferralLeaderboard(@Query('limit') limit?: number) {
        return this.usersService.getReferralLeaderboard(limit || 20);
    }

    /**
     * Get current user's referral stats
     * GET /api/v1/users/me/referral
     */
    @Get('me/referral')
    async getMyReferralStats(@CurrentUser() user: any) {
        return this.usersService.getReferralStats(user.id);
    }

    /**
     * Apply a referral code
     * POST /api/v1/users/me/apply-referral
     */
    @Post('me/apply-referral')
    async applyReferralCode(@CurrentUser() user: any, @Body() body: { code: string }) {
        return this.usersService.applyReferralCode(user.id, body.code);
    }

    /**
     * Initialize achievements for all existing users (one-time migration)
     * POST /api/v1/users/init-achievements
     */
    @Post('init-achievements')
    async initializeAllUsersAchievements() {
        return this.usersService.initializeAchievementsForAllUsers();
    }
    /**
     * Get user settings
     * GET /api/v1/users/me/settings
     */
    @Get('me/settings')
    async getSettings(@CurrentUser() user: any) {
        return this.usersService.getSettings(user.id);
    }

    /**
     * Update user settings
     * PUT /api/v1/users/me/settings
     */
    @Put('me/settings')
    async updateSettings(@CurrentUser() user: any, @Body() body: any) {
        return this.usersService.updateSettings(user.id, body);
    }
}
