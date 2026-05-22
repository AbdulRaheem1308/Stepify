import { IsString, IsNotEmpty, IsNumber, Min } from "class-validator";
import { ApiProperty } from "@nestjs/swagger";

export class MockSyncStepsDto {
  @ApiProperty({ description: "Target user ID to sync mock steps for" })
  @IsString()
  @IsNotEmpty()
  userId: string;

  @ApiProperty({ description: "Number of steps to mock", minimum: 0 })
  @IsNumber()
  @Min(0)
  stepCount: number;

  @ApiProperty({
    description: "Source of the steps (e.g. google_fit, apple_health, manual)",
  })
  @IsString()
  @IsNotEmpty()
  source: string;
}
