import {
    IsString,
    IsInt,
    IsOptional,
    IsEnum,
    IsBoolean,
    IsDateString,
    Min,
} from 'class-validator';

export enum ChallengeType {
    SOLO = 'SOLO',
    GROUP = 'GROUP',
    TIMED = 'TIMED',
    CORPORATE = 'CORPORATE',
}

export enum ChallengeDifficulty {
    EASY = 'EASY',
    MEDIUM = 'MEDIUM',
    HARD = 'HARD',
    EXTREME = 'EXTREME',
}

export enum ChallengeStatus {
    ONGOING = 'ONGOING',
    COMPLETED = 'COMPLETED',
    FAILED = 'FAILED',
    ABANDONED = 'ABANDONED',
}

export class CreateChallengeDto {
    @IsString()
    title: string;

    @IsString()
    description: string;

    @IsInt()
    @Min(100)
    stepTarget: number;

    @IsInt()
    @IsOptional()
    @Min(0)
    rewardCoins?: number;

    @IsInt()
    @IsOptional()
    @Min(0)
    rewardXp?: number;

    @IsInt()
    @Min(1)
    durationDays: number;

    @IsEnum(ChallengeType)
    @IsOptional()
    challengeType?: ChallengeType;

    @IsEnum(ChallengeDifficulty)
    @IsOptional()
    difficulty?: ChallengeDifficulty;

    @IsString()
    @IsOptional()
    imageUrl?: string;

    @IsBoolean()
    @IsOptional()
    isInviteOnly?: boolean;

    @IsInt()
    @IsOptional()
    maxParticipants?: number;

    @IsDateString()
    @IsOptional()
    startsAt?: string;

    @IsDateString()
    @IsOptional()
    endsAt?: string;
}

export class JoinChallengeDto {
    @IsString()
    challengeId: string;
}

export class UpdateChallengeProgressDto {
    @IsString()
    challengeId: string;

    @IsInt()
    @Min(0)
    stepsToAdd: number;
}
