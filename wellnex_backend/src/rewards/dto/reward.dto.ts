import { IsString, IsNotEmpty } from "class-validator";
import { ApiProperty } from "@nestjs/swagger";

export class RedeemRewardDto {
  @ApiProperty({
    example: "reward-123",
    description: "The ID of the reward to redeem",
  })
  @IsString()
  @IsNotEmpty()
  rewardId: string;
}
