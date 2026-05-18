import { Module } from '@nestjs/common';
import { StepsService } from './steps.service';
import { StepsController } from './steps.controller';
import { RewardsModule } from '../rewards/rewards.module';

@Module({
    imports: [RewardsModule],
    controllers: [StepsController],
    providers: [StepsService],
    exports: [StepsService],
})
export class StepsModule { }
