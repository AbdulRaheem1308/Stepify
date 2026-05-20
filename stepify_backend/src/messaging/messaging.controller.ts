import { Controller, Get, Post, Body, Param, UseGuards, ForbiddenException } from '@nestjs/common';
import { MessagingService } from './messaging.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@Controller('messaging')
@UseGuards(JwtAuthGuard)
export class MessagingController {
    constructor(private readonly messagingService: MessagingService) { }

    @Get('conversations/:userId')
    async getConversations(
        @Param('userId') userId: string,
        @CurrentUser() user: any
    ) {
        // IDOR Prevention: Support 'me' alias and block viewing conversations of other users
        const resolvedUserId = userId === 'me' ? user.id : userId;
        if (resolvedUserId && resolvedUserId !== user.id) {
            throw new ForbiddenException('Cannot query conversations for another user');
        }
        return this.messagingService.getConversations(resolvedUserId);
    }

    @Get('conversations/:id/messages')
    async getMessages(
        @Param('id') conversationId: string,
        @CurrentUser() user: any
    ) {
        // IDOR Prevention: Enforce that the user is actually a participant of this conversation
        const isParticipant = await this.messagingService.isParticipant(conversationId, user.id);
        if (!isParticipant) {
            throw new ForbiddenException('You are not a participant in this conversation');
        }
        return this.messagingService.getMessages(conversationId);
    }

    @Post('conversations/start')
    async startConversation(
        @Body() body: { userId: string, otherUserId: string },
        @CurrentUser() user: any
    ) {
        // IDOR Prevention: Prevent starting a conversation on behalf of another user
        const resolvedUserId = body.userId || user.id;
        if (body.userId && body.userId !== user.id) {
            throw new ForbiddenException('Cannot start a conversation as another user');
        }
        return this.messagingService.startConversation(resolvedUserId, body.otherUserId);
    }

    @Post('messages')
    async sendMessage(
        @Body() body: { conversationId: string, senderId: string, content: string },
        @CurrentUser() user: any
    ) {
        // IDOR Prevention: Ensure senderId matches authenticated user
        const resolvedSenderId = body.senderId || user.id;
        if (body.senderId && body.senderId !== user.id) {
            throw new ForbiddenException('Cannot send a message as another user');
        }
        // IDOR Prevention: Verify that user is actually a participant of this conversation
        const isParticipant = await this.messagingService.isParticipant(body.conversationId, user.id);
        if (!isParticipant) {
            throw new ForbiddenException('You cannot send messages to a conversation you are not part of');
        }
        return this.messagingService.sendMessage(body.conversationId, resolvedSenderId, body.content);
    }
}
