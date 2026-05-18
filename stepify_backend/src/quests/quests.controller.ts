import { Controller, Get, Post, Body, Param, UseGuards, Request, Put } from '@nestjs/common';
import { QuestsService } from './quests.service';

@Controller('quests')
export class QuestsController {
    constructor(private readonly questsService: QuestsService) { }

    @Get()
    async findAll(@Request() req: any) {
        // Ideally filter by user status, here returning all available
        return this.questsService.findAll();
    }

    @Post(':id/join')
    async joinQuest(@Param('id') questId: string, @Body('userId') userId: string) {
        return this.questsService.joinQuest(userId, questId);
    }

    @Get('my-quests/:userId')
    async getMyQuests(@Param('userId') userId: string) {
        return this.questsService.getUserQuests(userId);
    }
}
