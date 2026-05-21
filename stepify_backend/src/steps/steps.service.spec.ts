import { Test, TestingModule } from '@nestjs/testing';
import { StepsService } from './steps.service';
import { PrismaService } from '../prisma/prisma.service';
import { ConfigService } from '@nestjs/config';
import { RewardsService } from '../rewards/rewards.service';
import { RedisService } from '../redis/redis.service';
import { PostHogService } from '../analytics/posthog.service';
import { BadRequestException } from '@nestjs/common';
import { getQueueToken } from '@nestjs/bullmq';

// ── Mocks ──────────────────────────────────────────────────────────────────
const mockPrisma = {
  step: {
    findUnique: jest.fn(),
    upsert: jest.fn(),
    createMany: jest.fn(),
    findMany: jest.fn(),
    count: jest.fn(),
    aggregate: jest.fn(),
  },
  device: { findFirst: jest.fn() },
  streak: { upsert: jest.fn() },
  wallet: { upsert: jest.fn() },
  user: { findUnique: jest.fn() },
};

const mockConfig = {
  get: jest.fn((key: string, def?: any) => {
    const map: Record<string, any> = {
      CALORIES_PER_STEP: '0.04',
      KM_PER_STEP: '0.000762',
    };
    return map[key] ?? def;
  }),
};

const mockRewards = {
  processStepRewards: jest.fn(),
};

const mockRedis = {
  setNonce: jest.fn().mockResolvedValue(true),
};

const mockPostHog = {
  capture: jest.fn(),
};

const mockQueue = {
  add: jest.fn(),
};

// Minimal valid device mock
const boundDevice = { id: 'device-1', userId: 'user-1', identifier: 'test-device', isActive: true };

// ── Builders ───────────────────────────────────────────────────────────────
function buildSyncDto(overrides: Partial<any> = {}) {
  return {
    stepCount: 5000,
    date: new Date().toISOString().split('T')[0],
    source: 'health_connect',
    deviceIdentifier: 'test-device',
    ...overrides,
  };
}

// ── Tests ──────────────────────────────────────────────────────────────────
describe('StepsService', () => {
  let service: StepsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        StepsService,
        { provide: PrismaService, useValue: mockPrisma },
        { provide: ConfigService, useValue: mockConfig },
        { provide: RewardsService, useValue: mockRewards },
        { provide: PostHogService, useValue: mockPostHog },
        { provide: RedisService, useValue: mockRedis },
        { provide: getQueueToken('steps-processing'), useValue: mockQueue },
      ],
    }).compile();

    service = module.get<StepsService>(StepsService);
    jest.clearAllMocks();
  });

  // ── syncSteps ────────────────────────────────────────────────────────────
  describe('syncSteps()', () => {
    it('should throw BadRequestException if no deviceIdentifier provided', async () => {
      await expect(service.syncSteps('user-1', buildSyncDto({ deviceIdentifier: undefined }))).rejects.toThrow(BadRequestException);
    });

    it('should throw BadRequestException if device not registered', async () => {
      mockPrisma.device.findFirst.mockResolvedValue(null);
      await expect(service.syncSteps('user-1', buildSyncDto())).rejects.toThrow(BadRequestException);
    });

    it('should throw BadRequestException for negative step count', async () => {
      mockPrisma.device.findFirst.mockResolvedValue(boundDevice);
      await expect(service.syncSteps('user-1', buildSyncDto({ stepCount: -1 }))).rejects.toThrow(BadRequestException);
    });

    it('should throw BadRequestException for step count exceeding MAX_STEPS_PER_DAY (60000)', async () => {
      mockPrisma.device.findFirst.mockResolvedValue(boundDevice);
      await expect(service.syncSteps('user-1', buildSyncDto({ stepCount: 60001 }))).rejects.toThrow(BadRequestException);
    });

    it('should throw BadRequestException for jailbroken device', async () => {
      mockPrisma.device.findFirst.mockResolvedValue(boundDevice);
      await expect(
        service.syncSteps('user-1', buildSyncDto({ integrity: { isJailBroken: true, isMockLocation: false } }))
      ).rejects.toThrow(BadRequestException);
    });

    it('should throw BadRequestException for mock location device', async () => {
      mockPrisma.device.findFirst.mockResolvedValue(boundDevice);
      await expect(
        service.syncSteps('user-1', buildSyncDto({ integrity: { isJailBroken: false, isMockLocation: true } }))
      ).rejects.toThrow(BadRequestException);
    });

    it('should reject duplicate nonce (replay attack)', async () => {
      mockPrisma.device.findFirst.mockResolvedValue(boundDevice);
      mockRedis.setNonce.mockResolvedValue(false); // nonce already seen
      await expect(service.syncSteps('user-1', buildSyncDto({ nonce: 'replay-nonce' }))).rejects.toThrow(BadRequestException);
    });

    it('should reject requests with excessive timestamp drift (> 5 minutes)', async () => {
      mockPrisma.device.findFirst.mockResolvedValue(boundDevice);
      const oldTimestamp = Date.now() - 6 * 60 * 1000; // 6 minutes ago
      await expect(service.syncSteps('user-1', buildSyncDto({ timestamp: oldTimestamp }))).rejects.toThrow(BadRequestException);
    });

    it('should use "highest wins" strategy — not downgrade existing step count', async () => {
      mockPrisma.device.findFirst.mockResolvedValue(boundDevice);
      // Existing record has MORE steps
      mockPrisma.step.findUnique.mockResolvedValue({ stepCount: 8000, source: 'google_fit', activeMinutes: 90 });
      mockPrisma.step.upsert.mockResolvedValue({ stepCount: 8000, caloriesBurned: 320, distanceKm: 6.1, activeMinutes: 90 });
      mockQueue.add.mockResolvedValue({});

      await service.syncSteps('user-1', buildSyncDto({ stepCount: 5000 }));

      // The upsert call should contain effectiveStepCount = 8000 (highest wins)
      expect(mockPrisma.step.upsert).toHaveBeenCalledWith(
        expect.objectContaining({
          update: expect.objectContaining({ stepCount: 8000 }),
        }),
      );
    });

    it('should calculate calories and distance correctly', async () => {
      mockPrisma.device.findFirst.mockResolvedValue(boundDevice);
      mockPrisma.step.findUnique.mockResolvedValue(null);
      mockPrisma.step.upsert.mockImplementation((args) => args.create);
      mockQueue.add.mockResolvedValue({});

      await service.syncSteps('user-1', buildSyncDto({ stepCount: 10000 }));

      const upsertCall = mockPrisma.step.upsert.mock.calls[0][0];
      // 10000 steps * 0.04 cal/step = 400 calories
      expect(upsertCall.create.caloriesBurned).toBe(400);
      // 10000 steps * 0.000762 km/step = 7.62 km
      expect(upsertCall.create.distanceKm).toBe(7.62);
    });

    it('should enqueue a background job after successful step sync', async () => {
      mockPrisma.device.findFirst.mockResolvedValue(boundDevice);
      mockPrisma.step.findUnique.mockResolvedValue(null);
      mockPrisma.step.upsert.mockResolvedValue({});
      mockQueue.add.mockResolvedValue({});

      await service.syncSteps('user-1', buildSyncDto({ stepCount: 5000 }));

      expect(mockQueue.add).toHaveBeenCalledWith('process-sync', expect.objectContaining({ userId: 'user-1' }));
    });
  });

  // ── getTodaySteps ─────────────────────────────────────────────────────────
  describe('getTodaySteps()', () => {
    it('should return progress as 0 when no steps logged today', async () => {
      mockPrisma.step.count.mockResolvedValue(1); // prevent demo seed
      mockPrisma.step.findUnique.mockResolvedValue(null);
      mockPrisma.user.findUnique.mockResolvedValue({ dailyStepGoal: 10000 });

      const result = await service.getTodaySteps('user-1');

      expect(result.stepCount).toBe(0);
      expect(result.progress).toBe(0);
      expect(result.goalReached).toBe(false);
    });

    it('should return progress as 100% when goal is reached', async () => {
      mockPrisma.step.count.mockResolvedValue(1);
      mockPrisma.step.findUnique.mockResolvedValue({ stepCount: 12000, caloriesBurned: 480, distanceKm: 9.14, activeMinutes: 110 });
      mockPrisma.user.findUnique.mockResolvedValue({ dailyStepGoal: 10000 });

      const result = await service.getTodaySteps('user-1');

      expect(result.progress).toBe(100);
      expect(result.goalReached).toBe(true);
    });
  });

  // ── getHistory ────────────────────────────────────────────────────────────
  describe('getHistory()', () => {
    it('should return paginated history with correct totalPages', async () => {
      mockPrisma.step.findMany.mockResolvedValue([{ stepCount: 8000 }]);
      mockPrisma.step.count.mockResolvedValue(35);

      const result = await service.getHistory('user-1', 1, 30);

      expect(result.pagination.total).toBe(35);
      expect(result.pagination.totalPages).toBe(2);
    });
  });
});
