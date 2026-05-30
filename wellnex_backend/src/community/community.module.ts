import { Module } from "@nestjs/common";
import { CommunityService } from "./community.service";
import { CommunityController } from "./community.controller";
import { PrismaModule } from "../prisma/prisma.module";
import { LeaderboardGateway } from "./leaderboard.gateway";
import { AuthModule } from "../auth/auth.module";
import { NotificationsModule } from "../notifications/notifications.module";

@Module({
  imports: [PrismaModule, AuthModule, NotificationsModule],
  controllers: [CommunityController],
  providers: [CommunityService, LeaderboardGateway],
  exports: [CommunityService],
})
export class CommunityModule {}
