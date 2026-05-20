import { Module } from '@nestjs/common';
import { AdminController } from './admin.controller';
import { StepsModule } from '../steps/steps.module';
import { RedisModule } from '../redis/redis.module';

@Module({
    imports: [StepsModule, RedisModule],
    controllers: [AdminController],
})
export class AdminModule { }
