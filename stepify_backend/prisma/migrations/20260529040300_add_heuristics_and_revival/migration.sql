-- AlterEnum
ALTER TYPE "ChallengeStatus" ADD VALUE 'NEEDS_REVIVAL';

-- AlterEnum
ALTER TYPE "QuestStatus" ADD VALUE 'NEEDS_REVIVAL';

-- AlterEnum
ALTER TYPE "TransactionType" ADD VALUE 'REVIVAL';

-- AlterTable
ALTER TABLE "challenges" ADD COLUMN     "gracePeriodHours" INTEGER,
ADD COLUMN     "howItWorks" TEXT,
ADD COLUMN     "revivalExtensionHours" INTEGER;

-- AlterTable
ALTER TABLE "quest_stages" ADD COLUMN     "durationDays" INTEGER,
ADD COLUMN     "gracePeriodHours" INTEGER,
ADD COLUMN     "revivalExtensionHours" INTEGER;

-- AlterTable
ALTER TABLE "quests" ADD COLUMN     "howItWorks" TEXT;

-- AlterTable
ALTER TABLE "user_challenges" ADD COLUMN     "deadline" TIMESTAMP(3),
ADD COLUMN     "revivalCount" INTEGER NOT NULL DEFAULT 0;

-- AlterTable
ALTER TABLE "user_quests" ADD COLUMN     "deadline" TIMESTAMP(3),
ADD COLUMN     "revivalCount" INTEGER NOT NULL DEFAULT 0;
