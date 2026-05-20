import { Controller, Get, Post, Body, Param, UseGuards, ForbiddenException } from '@nestjs/common';
import { QuestsService } from './quests.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@Controller('quests')
@UseGuards(JwtAuthGuard)
export class QuestsController {
    constructor(private readonly questsService: QuestsService) { }

    @Get()
    async findAll() {
        // Returns all available quests
        return this.questsService.findAll();
    }

    @Post(':id/join')
    async joinQuest(
        @Param('id') questId: string,
        @Body('userId') userId: string,
        @CurrentUser() user: any
    ) {
        // IDOR Prevention: Enforce that body userId matches current token
        if (userId && userId !== user.id) {
            throw new ForbiddenException('Cannot join a quest on behalf of another user');
        }
        return this.questsService.joinQuest(user.id, questId);
    }

    @Get('my-quests/:userId')
    async getMyQuests(
        @Param('userId') userId: string,
        @CurrentUser() user: any
    ) {
        // IDOR Prevention: Support backwards compatibility for 'me' and enforce strict user checking
        const resolvedUserId = userId === 'me' ? user.id : userId;
        if (resolvedUserId && resolvedUserId !== user.id) {
            throw new ForbiddenException('Cannot view quests belonging to another user');
        }
        return this.questsService.getUserQuests(user.id);
    }
}
