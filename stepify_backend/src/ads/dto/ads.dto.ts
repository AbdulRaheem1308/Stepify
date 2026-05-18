import { IsString, IsOptional, IsEnum } from 'class-validator';
import { AdType } from '@prisma/client';

export class ClaimAdRewardDto {
    @IsEnum(AdType)
    adType: AdType;

    @IsOptional()
    @IsString()
    adUnitId?: string;
}
