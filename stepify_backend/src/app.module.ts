import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';

// Core modules
import { PrismaModule } from './prisma/prisma.module';
import { RedisModule } from './redis/redis.module';

// Feature modules
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { StepsModule } from './steps/steps.module';
import { RewardsModule } from './rewards/rewards.module';
import { AdsModule } from './ads/ads.module';
import { ChallengesModule } from './challenges/challenges.module';
import { FriendsModule } from './friends/friends.module';
import { OffersModule } from './offers/offers.module';
import { CommunityModule } from './community/community.module';
import { DevicesModule } from './devices/devices.module';
import { NotificationsModule } from './notifications/notifications.module';
import { TeamsModule } from './teams/teams.module';
import { CompaniesModule } from './companies/companies.module';
import { QuestsModule } from './quests/quests.module';
import { MessagingModule } from './messaging/messaging.module';

// Controllers
import { HealthController } from './health.controller';

@Module({
    imports: [
        // Configuration
        ConfigModule.forRoot({
            isGlobal: true,
            envFilePath: '.env',
        }),

        // Rate limiting
        ThrottlerModule.forRoot([{
            ttl: 60000, // 1 minute
            limit: 100, // 100 requests per minute
        }]),

        // Core
        PrismaModule,
        RedisModule,

        // Features
        AuthModule,
        UsersModule,
        StepsModule,
        RewardsModule,
        AdsModule,
        ChallengesModule,
        FriendsModule,
        OffersModule,
        CommunityModule,
        DevicesModule,
        NotificationsModule,
        TeamsModule,
        CompaniesModule,
        QuestsModule,
        MessagingModule,
    ],
    controllers: [HealthController],
    providers: [
        {
            provide: APP_GUARD,
            useClass: ThrottlerGuard,
        },
    ],
})
export class AppModule { }

