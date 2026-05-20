import { Controller, Get, Post, Delete, Param, Query, Body, UseGuards, Request } from '@nestjs/common';
import { NotificationsService } from './notifications.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { IsString, IsNotEmpty } from 'class-validator';

class RegisterFcmTokenDto {
    @IsString()
    @IsNotEmpty()
    token: string;
}

@Controller('notifications')
@UseGuards(JwtAuthGuard)
export class NotificationsController {
    constructor(private readonly notificationsService: NotificationsService) { }

    /**
     * GET /api/v1/notifications
     * Get in-app notifications for the current user
     */
    @Get()
    async getNotifications(@Request() req: any, @Query('limit') limit?: number) {
        return this.notificationsService.getUserNotifications(req.user.sub, limit || 20);
    }

    /**
     * POST /api/v1/notifications/fcm-token
     * Register or update FCM push token for the current device session.
     * Call this on app launch, after login, and on FCM token refresh.
     */
    @Post('fcm-token')
    async registerFcmToken(@Request() req: any, @Body() dto: RegisterFcmTokenDto) {
        return this.notificationsService.registerFcmToken(req.user.sub, dto.token);
    }

    /**
     * POST /api/v1/notifications/:id/read
     * Mark a specific notification as read (pass 'all' to mark all)
     */
    @Post(':id/read')
    async markAsRead(@Request() req: any, @Param('id') id: string) {
        return this.notificationsService.markAsRead(req.user.sub, id);
    }

    /**
     * DELETE /api/v1/notifications/:id
     * Delete a specific notification
     */
    @Delete(':id')
    async deleteNotification(@Request() req: any, @Param('id') id: string) {
        return this.notificationsService.deleteNotification(req.user.sub, id);
    }
}
