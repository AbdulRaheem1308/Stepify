import { Controller, Get, Post, Body, Param, UseGuards, Request, Put, Query } from '@nestjs/common';
import { CompaniesService } from './companies.service';

@Controller('companies')
export class CompaniesController {
    constructor(private readonly companiesService: CompaniesService) { }

    @Post()
    async create(@Body() body: any) {
        return this.companiesService.createCompany(body);
    }

    @Get()
    async findAll() {
        return this.companiesService.findAll();
    }

    @Post(':joinCode/join')
    async joinCompany(@Param('joinCode') joinCode: String, @Body('userId') userId: string) {
        // In a real app, userId comes from JWT guard
        return this.companiesService.joinCompany(joinCode as string, userId);
    }

    @Get(':id/leaderboard')
    async getLeaderboard(@Param('id') id: string) {
        return this.companiesService.getCompanyLeaderboard(id);
    }

    @Get('my-company/:userId')
    async getMyCompany(@Param('userId') userId: string) {
        return this.companiesService.getUserCompany(userId);
    }
}
