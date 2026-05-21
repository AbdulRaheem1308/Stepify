import { Module } from "@nestjs/common";
import { CommunityService } from "./community.service";
import { CommunityController } from "./community.controller";
import { PrismaModule } from "../prisma/prisma.module";
import { LeaderboardGateway } from "./leaderboard.gateway";

@Module({
  imports: [PrismaModule],
  controllers: [CommunityController],
  providers: [CommunityService, LeaderboardGateway],
  exports: [CommunityService],
})
export class CommunityModule {}
