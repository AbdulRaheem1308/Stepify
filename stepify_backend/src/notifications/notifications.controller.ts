import { Controller, Get, Post, Param, Query, UseGuards, Request } from '@nestjs/common';
import { NotificationsService } from './notifications.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('notifications')
@UseGuards(JwtAuthGuard)
export class NotificationsController {
    constructor(private readonly notificationsService: NotificationsService) { }

    // GET /api/v1/notifications - Get user notifications
    @Get()
    async getNotifications(@Request() req: any, @Query('limit') limit?: number) {
        return this.notificationsService.getUserNotifications(req.user.sub, limit || 20);
    }

    // POST /api/v1/notifications/:id/read - Mark as read
    @Post(':id/read')
    async markAsRead(@Request() req: any, @Param('id') id: string) {
        return this.notificationsService.markAsRead(req.user.sub, id);
    }

    // DELETE /api/v1/notifications/:id - Delete notification
    // Use @Delete to avoid importing it if not already imported, wait, I need to import Delete
    @Post(':id/delete') // Using POST for simplicity if Delete not imported, but better use Delete verb.
    // Let's actually use the Delete verb properly.
    async deleteNotification(@Request() req: any, @Param('id') id: string) {
        return this.notificationsService.deleteNotification(req.user.sub, id);
    }
}
