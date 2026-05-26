import { Module } from "@nestjs/common";
import { RewardsService } from "./rewards.service";
import { RewardsController } from "./rewards.controller";
import { QuestsModule } from "../quests/quests.module";

import { RewardsCronService } from "./rewards.cron.service";

@Module({
  imports: [QuestsModule],
  controllers: [RewardsController],
  providers: [RewardsService, RewardsCronService],
  exports: [RewardsService],
})
export class RewardsModule {}
