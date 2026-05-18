import { Controller, Get, Post, Param, Query, UseGuards, Request } from '@nestjs/common';
import { OffersService } from './offers.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('offers')
@UseGuards(JwtAuthGuard)
export class OffersController {
    constructor(private readonly offersService: OffersService) { }

    // GET /api/v1/offers - List all active offers
    @Get()
    async findAll() {
        return this.offersService.findAllActive();
    }

    // GET /api/v1/offers/my - Get user's offers (Screen 17)
    @Get('my')
    async getMyOffers(@Request() req: any, @Query('status') status?: string) {
        return this.offersService.getUserOffers(req.user.sub, status);
    }

    // POST /api/v1/offers/:id/start - Start tracking an offer
    @Post(':id/start')
    async startOffer(@Request() req: any, @Param('id') offerId: string) {
        return this.offersService.startOffer(req.user.sub, offerId);
    }

    // POST /api/v1/offers/:id/complete - Complete an offer and claim reward
    @Post(':id/complete')
    async completeOffer(@Request() req: any, @Param('id') offerId: string) {
        return this.offersService.completeOffer(req.user.sub, offerId);
    }
}
