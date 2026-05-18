import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

// For now, we'll generate notifications dynamically from transactions
// In a real app, you'd have a dedicated Notification model

export interface NotificationItem {
    id: string;
    title: string;
    message: string;
    type: string;
    isRead: boolean;
    createdAt: Date;
}

@Injectable()
export class NotificationsService {
    constructor(private prisma: PrismaService) { }

    // Get user notifications from DB
    async getUserNotifications(userId: string, limit = 20): Promise<NotificationItem[]> {
        const notifications = await (this.prisma as any).notification.findMany({
            where: { userId },
            orderBy: { createdAt: 'desc' },
            take: limit,
        }) as any[];

        // Map to interface (though model is very similar)
        return notifications.map((n: any) => ({
            id: n.id,
            title: n.title,
            message: n.message,
            type: n.type,
            isRead: n.isRead,
            createdAt: n.createdAt,
        }));
    }

    // Mark notification as read
    async markAsRead(userId: string, notificationId: string) {
        if (notificationId === 'all') {
            await (this.prisma as any).notification.updateMany({
                where: { userId, isRead: false },
                data: { isRead: true },
            });
            return { success: true };
        }

        await (this.prisma as any).notification.update({
            where: { id: notificationId, userId }, // Ensure ownership
            data: { isRead: true },
        });
        return { success: true };
    }

    // Delete notification
    async deleteNotification(userId: string, notificationId: string) {
        await (this.prisma as any).notification.delete({
            where: { id: notificationId, userId }, // Ensure ownership
        });
        return { success: true };
    }
}
