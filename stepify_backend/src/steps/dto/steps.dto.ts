import { IsNumber, IsString, IsOptional, IsDateString, Min } from 'class-validator';

export class SyncStepsDto {
    @IsDateString()
    date: string;

    @IsNumber()
    @Min(0)
    stepCount: number;

    @IsOptional()
    @IsNumber()
    @Min(0)
    activeMinutes?: number;

    @IsOptional()
    @IsString()
    source?: string; // 'manual', 'google_fit', 'apple_health'
}
