import { Module } from '@nestjs/common';
import { AdsService } from './ads.service';
import { AdsController } from './ads.controller';
import { RewardsModule } from '../rewards/rewards.module';

@Module({
    imports: [RewardsModule],
    controllers: [AdsController],
    providers: [AdsService],
})
export class AdsModule { }
