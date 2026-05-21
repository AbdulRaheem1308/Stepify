import { Module, forwardRef } from "@nestjs/common";
import { RewardsService } from "./rewards.service";
import { RewardsController } from "./rewards.controller";
import { QuestsModule } from "../quests/quests.module";

@Module({
  imports: [QuestsModule],
  controllers: [RewardsController],
  providers: [RewardsService],
  exports: [RewardsService],
})
export class RewardsModule {}
