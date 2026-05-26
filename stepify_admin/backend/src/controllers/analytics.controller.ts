import { Request, Response, NextFunction } from "express";
import { prisma } from "../config/database";

export const getSummary = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const totalUsers = await prisma.user.count();
    const activeUsers = await prisma.user.count({ where: { isActive: true } });
    const totalStepsGroup = await prisma.step.aggregate({ _sum: { stepCount: true } });
    const totalCoinsGroup = await prisma.wallet.aggregate({ _sum: { balance: true } });
    const totalAdViews = await prisma.adView.count();
    const totalChallenges = await prisma.challenge.count();
    const activeStreaksCount = await prisma.streak.count({ where: { currentStreak: { gt: 0 } } });
    const totalCompanies = await prisma.company.count();

    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    const recentSteps = await prisma.step.groupBy({
      by: ["date"],
      where: { date: { gte: sevenDaysAgo } },
      _sum: { stepCount: true },
      orderBy: { date: "asc" }
    });

    const chartData = recentSteps.map(s => ({
      date: s.date.toISOString().split("T")[0],
      steps: s._sum.stepCount || 0
    }));

    res.json({
      success: true,
      data: {
        totalUsers,
        activeUsers,
        totalSteps: totalStepsGroup._sum.stepCount || 0,
        totalCoins: totalCoinsGroup._sum.balance || 0,
        totalAdViews,
        totalChallenges,
        activeStreaksCount,
        totalCompanies,
        chartData
      }
    });
  } catch (error) {
    next(error);
  }
};

export const getInteractions = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const users = await prisma.user.findMany({
      select: {
        id: true,
        age: true,
        dailyStepGoal: true,
        fitnessLevel: true,
        activityPreferences: true,
        steps: { select: { activeMinutes: true } }
      }
    });

    let totalActiveMinutes = 0;
    let totalLoggedDays = 0;
    const activityPreferencesMap: { [key: string]: number } = {};
    const fitnessLevelMap: { [key: string]: number } = {};

    users.forEach(u => {
      u.activityPreferences.forEach(pref => {
        activityPreferencesMap[pref] = (activityPreferencesMap[pref] || 0) + 1;
      });

      if (u.fitnessLevel) {
        fitnessLevelMap[u.fitnessLevel] = (fitnessLevelMap[u.fitnessLevel] || 0) + 1;
      }

      u.steps.forEach(s => {
        totalActiveMinutes += s.activeMinutes;
        totalLoggedDays++;
      });
    });

    const averageActiveMinutesPerDay = totalLoggedDays > 0 ? (totalActiveMinutes / totalLoggedDays).toFixed(2) : "0.00";

    const totalEarnedAdCoins = await prisma.transaction.aggregate({
      _sum: { points: true },
      where: { type: "AD_REWARD" }
    });

    const totalRedeemedCoins = await prisma.transaction.aggregate({
      _sum: { points: true },
      where: { type: "REDEMPTION" }
    });

    const totalAdCompleted = await prisma.adView.count({
      where: { pointsEarned: { gt: 0 } }
    });

    res.json({
      success: true,
      data: {
        averageActiveMinutesPerDay: parseFloat(averageActiveMinutesPerDay),
        totalActiveMinutesLogged: totalActiveMinutes,
        preferences: Object.entries(activityPreferencesMap).map(([name, value]) => ({ name, value })),
        fitnessLevels: Object.entries(fitnessLevelMap).map(([name, value]) => ({ name, value })),
        adCompletionStats: {
          totalAdViewsCompleted: totalAdCompleted,
          totalCoinsAwardedFromAds: totalEarnedAdCoins._sum.points || 0
        },
        coinVelocity: {
          totalEarnedFromAds: totalEarnedAdCoins._sum.points || 0,
          totalRedeemedForRewards: Math.abs(totalRedeemedCoins._sum.points || 0)
        }
      }
    });
  } catch (error) {
    next(error);
  }
};
