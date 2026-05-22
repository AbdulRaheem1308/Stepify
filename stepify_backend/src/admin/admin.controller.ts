import { Controller, Get, Post, Body, Header, UseGuards } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";
import { RedisService } from "../redis/redis.service";
import { StepsService } from "../steps/steps.service";
import { getAdminDashboardHtml } from "./admin.view";
import { AdminApiKeyGuard } from "./guards/admin-api-key.guard";
import { MockSyncStepsDto } from "./dto/mock-sync-steps.dto";
import { ApiTags, ApiOperation, ApiSecurity } from "@nestjs/swagger";

@ApiTags("Admin")
@Controller("admin")
export class AdminController {
  constructor(
    private readonly prisma: PrismaService,
    private readonly redisService: RedisService,
    private readonly stepsService: StepsService,
  ) {}

  @Get()
  @Header("Content-Type", "text/html")
  @ApiOperation({ summary: "Render the admin dashboard HTML" })
  async getDashboardHtml() {
    return getAdminDashboardHtml();
  }

  @Get("api/metrics")
  @UseGuards(AdminApiKeyGuard)
  @ApiSecurity("api-key")
  @ApiOperation({ summary: "Get aggregated system metrics for the dashboard" })
  async getMetrics() {
    const usersCount = await this.prisma.user.count();

    const totalSteps = await this.prisma.step.aggregate({
      _sum: { stepCount: true },
    });

    const totalCoins = await this.prisma.wallet.aggregate({
      _sum: { balance: true },
    });

    // Mask PII data slightly unless full access is required.
    // For now, retaining basic contact info as it's an admin dashboard.
    const users = await this.prisma.user.findMany({
      take: 15,
      orderBy: { createdAt: "desc" },
      select: { id: true, name: true, phone: true, email: true },
    });

    const recentTransactions = await this.prisma.transaction.findMany({
      where: { type: "STEPS" },
      take: 6,
      orderBy: { createdAt: "desc" },
      include: {
        user: {
          select: { name: true, phone: true, email: true },
        },
      },
    });

    // 30-Day aggregate steps for activity chart
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const stepsData = await this.prisma.step.groupBy({
      by: ["date"],
      where: {
        date: { gte: thirtyDaysAgo },
      },
      _sum: { stepCount: true },
      orderBy: { date: "asc" },
    });

    const chartData = stepsData.map((d) => {
      const dateStr = d.date.toISOString().split("T")[0];
      return {
        date: dateStr,
        steps: d._sum.stepCount || 0,
      };
    });

    return {
      usersCount,
      stepsSum: totalSteps._sum.stepCount || 0,
      coinsSum: totalCoins._sum.balance || 0,
      users,
      recentTransactions,
      chartData,
    };
  }

  @Post("api/mock/steps")
  @UseGuards(AdminApiKeyGuard)
  @ApiSecurity("api-key")
  @ApiOperation({ summary: "Mock a step synchronization event (Admin Only)" })
  async mockSyncSteps(@Body() body: MockSyncStepsDto) {
    const nonce = `mock-nonce-${Math.random().toString(36).substring(2, 11)}-${Date.now()}`;
    const timestamp = Date.now();
    const dateStr = new Date().toISOString().split("T")[0];

    const mockDeviceIdentifier = "admin-attested-device-uuid";
    const existingDevice = await this.prisma.device.findFirst({
      where: {
        userId: body.userId,
        identifier: mockDeviceIdentifier,
        isActive: true,
      },
    });

    if (!existingDevice) {
      await this.prisma.device.create({
        data: {
          userId: body.userId,
          name: "Admin Attestation Simulator",
          type: "PHONE",
          identifier: mockDeviceIdentifier,
          isActive: true,
        },
      });
    }

    return this.stepsService.syncSteps(body.userId, {
      deviceIdentifier: mockDeviceIdentifier,
      date: dateStr,
      stepCount: body.stepCount,
      source: body.source,
      nonce: nonce,
      timestamp: timestamp,
      integrity: {
        isJailBroken: false,
        isRealDevice: true,
        isMockLocation: false,
      },
    });
  }

  @Post("api/mock/reset-nonces")
  @UseGuards(AdminApiKeyGuard)
  @ApiSecurity("api-key")
  @ApiOperation({ summary: "Reset Redis replay nonces (Admin Only)" })
  async resetNonces() {
    const client = this.redisService.getClient();
    if (client.status === "ready") {
      const keys = await client.keys("nonce:*");
      if (keys.length > 0) {
        await client.del(...keys);
      }
      return { status: "success", flushedCount: keys.length };
    }
    return {
      status: "mock_in_memory_reset",
      message:
        "No Redis connected. Local memory nonces automatically recycled.",
    };
  }
}
