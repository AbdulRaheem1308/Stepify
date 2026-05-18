import { Controller, Get, Post, Body, Param, UseGuards, Request } from '@nestjs/common';
import { MessagingService } from './messaging.service';

@Controller('messaging')
export class MessagingController {
    constructor(private readonly messagingService: MessagingService) { }

    @Get('conversations/:userId')
    async getConversations(@Param('userId') userId: string) {
        return this.messagingService.getConversations(userId);
    }

    @Get('conversations/:id/messages')
    async getMessages(@Param('id') conversationId: string) {
        return this.messagingService.getMessages(conversationId);
    }

    @Post('conversations/start')
    async startConversation(@Body() body: { userId: string, otherUserId: string }) {
        return this.messagingService.startConversation(body.userId, body.otherUserId);
    }

    @Post('messages')
    async sendMessage(@Body() body: { conversationId: string, senderId: string, content: string }) {
        return this.messagingService.sendMessage(body.conversationId, body.senderId, body.content);
    }
}
