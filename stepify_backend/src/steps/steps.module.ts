import { Module } from "@nestjs/common";
import { StepsService } from "./steps.service";
import { StepsController } from "./steps.controller";
import { RewardsModule } from "../rewards/rewards.module";
import { BullModule } from "@nestjs/bullmq";
import { LeaderboardGateway } from "./gateways/leaderboard.gateway";
import { StepsProcessor } from "./steps.processor";

@Module({
  imports: [
    RewardsModule,
    BullModule.registerQueue({
      name: "steps-processing",
    }),
  ],
  controllers: [StepsController],
  providers: [StepsService, LeaderboardGateway, StepsProcessor],
  exports: [StepsService, LeaderboardGateway],
})
export class StepsModule {}
