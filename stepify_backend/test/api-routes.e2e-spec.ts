import { Test, TestingModule } from '@nestjs/testing';
import {
  Controller,
  Get,
  Post,
  Body,
  Req,
  INestApplication,
  UseGuards,
  UnauthorizedException,
  BadRequestException,
} from '@nestjs/common';
import * as request from 'supertest';
import { ThrottlerModule } from '@nestjs/throttler';
import { JwtModule, JwtService } from '@nestjs/jwt';
import { APP_GUARD } from '@nestjs/core';
import { ThrottlerGuard } from '@nestjs/throttler';

// ── Lightweight mock controllers that simulate real API behaviour ────────────

const mockUserStore: Record<string, any> = {};
const mockOtpStore: Record<string, string> = {};

@Controller('api/v1/auth')
class MockAuthController {
  constructor(private jwtService: JwtService) {}

  @Post('send-otp')
  sendOtp(@Body() body: any) {
    const identifier = body.phone || body.email;
    if (!identifier) throw new BadRequestException('Phone or email required');
    mockOtpStore[identifier] = '123456'; // Always issue 123456 in test mode
    return { message: 'OTP sent', expiresIn: 300 };
  }

  @Post('verify-otp')
  verifyOtp(@Body() body: any) {
    const identifier = body.phone || body.email;
    if (!identifier) throw new BadRequestException('Phone or email required');
    if (mockOtpStore[identifier] !== body.otp) {
      throw new UnauthorizedException('Invalid OTP');
    }
    delete mockOtpStore[identifier];

    let user = mockUserStore[identifier];
    const isNewUser = !user;
    if (!user) {
      user = { id: `user-${Date.now()}`, phone: body.phone, email: body.email, name: null };
      mockUserStore[identifier] = user;
    }

    const accessToken = this.jwtService.sign({ sub: user.id });
    const refreshToken = this.jwtService.sign({ sub: user.id }, { expiresIn: '7d' });

    return { tokens: { accessToken, refreshToken }, user, isNewUser };
  }

  @Post('refresh')
  refresh(@Body() body: any) {
    try {
      const payload = this.jwtService.verify(body.refreshToken);
      const accessToken = this.jwtService.sign({ sub: payload.sub });
      const refreshToken = this.jwtService.sign({ sub: payload.sub }, { expiresIn: '7d' });
      return { accessToken, refreshToken };
    } catch {
      throw new UnauthorizedException('Invalid refresh token');
    }
  }

  @Post('social-login')
  socialLogin(@Body() body: any) {
    if (!body.idToken) throw new BadRequestException('idToken is required');
    // Simulate successful social login
    const user = { id: 'social-user-1', email: 'user@gmail.com', name: 'Test User' };
    const accessToken = this.jwtService.sign({ sub: user.id });
    const refreshToken = this.jwtService.sign({ sub: user.id }, { expiresIn: '7d' });
    return { tokens: { accessToken, refreshToken }, user, isNewUser: false };
  }
}

// ── Mock Steps Controller ──────────────────────────────────────────────────

const mockStepsDb: Record<string, any> = {
  'user-steps-1': { stepCount: 8500, caloriesBurned: 340, distanceKm: 6.5, activeMinutes: 77, goal: 10000 },
};

@Controller('api/v1/steps')
class MockStepsController {
  @Get('today')
  getToday(@Req() req: any) {
    const userId = req.headers['x-user-id'] || 'user-steps-1';
    const data = mockStepsDb[userId] || { stepCount: 0, caloriesBurned: 0, distanceKm: 0, activeMinutes: 0, goal: 10000 };
    return {
      ...data,
      progress: Math.min(Math.round((data.stepCount / data.goal) * 100), 100),
      goalReached: data.stepCount >= data.goal,
    };
  }

  @Get('history')
  getHistory() {
    return { data: [{ stepCount: 8500, date: '2025-05-20' }], pagination: { page: 1, limit: 30, total: 1, totalPages: 1 } };
  }

  @Get('weekly')
  getWeekly() {
    return { totalSteps: 52000, totalCalories: 2080, averageSteps: 7428, activeDays: 7 };
  }
}

// ── Mock Rewards Controller ────────────────────────────────────────────────

@Controller('api/v1/rewards')
class MockRewardsController {
  @Get('wallet')
  getWallet() {
    return { balance: 1500, lifetimePoints: 3200, monthlyXp: 450 };
  }

  @Get('catalog')
  getCatalog() {
    return [
      { id: 'r-1', title: 'Coffee Voucher', coinCost: 300, canAfford: true, inStock: true },
      { id: 'r-2', title: 'Nike Discount', coinCost: 500, canAfford: true, inStock: true },
    ];
  }

  @Post('redeem/:id')
  redeem() {
    return { success: true, voucherCode: 'STEP-TESTCODE', newBalance: 1200 };
  }

  @Get('streak')
  getStreak() {
    return { currentStreak: 7, longestStreak: 14, nextMilestone: 30, daysToMilestone: 23 };
  }
}

// ── Tests ──────────────────────────────────────────────────────────────────
describe('API Routes (e2e)', () => {
  let app: INestApplication;
  let jwtToken: string;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [
        ThrottlerModule.forRoot([{ ttl: 60000, limit: 1000 }]),
        JwtModule.register({ secret: 'test-secret', signOptions: { expiresIn: '1h' } }),
      ],
      controllers: [MockAuthController, MockStepsController, MockRewardsController],
      providers: [{ provide: APP_GUARD, useClass: ThrottlerGuard }],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();

    // Seed OTP and get a valid token for authenticated tests
    mockOtpStore['+919876543210'] = '123456';
    const loginRes = await request(app.getHttpServer())
      .post('/api/v1/auth/verify-otp')
      .send({ phone: '+919876543210', otp: '123456' });
    jwtToken = loginRes.body.tokens?.accessToken;
  });

  afterAll(async () => {
    await app.close();
  });

  // ── Auth Routes ──────────────────────────────────────────────────────────
  describe('POST /api/v1/auth/send-otp', () => {
    it('should return 201 with expiresIn when valid phone provided', () => {
      return request(app.getHttpServer())
        .post('/api/v1/auth/send-otp')
        .send({ phone: '+919876543210' })
        .expect(201)
        .expect((res) => {
          expect(res.body.message).toBeDefined();
          expect(res.body.expiresIn).toBe(300);
        });
    });

    it('should return 400 if no phone or email provided', () => {
      return request(app.getHttpServer())
        .post('/api/v1/auth/send-otp')
        .send({})
        .expect(400);
    });
  });

  describe('POST /api/v1/auth/verify-otp', () => {
    it('should return tokens and user on valid OTP', async () => {
      mockOtpStore['+910000000001'] = '123456';
      return request(app.getHttpServer())
        .post('/api/v1/auth/verify-otp')
        .send({ phone: '+910000000001', otp: '123456' })
        .expect(201)
        .expect((res) => {
          expect(res.body.tokens.accessToken).toBeDefined();
          expect(res.body.tokens.refreshToken).toBeDefined();
          expect(res.body.isNewUser).toBe(true);
        });
    });

    it('should return 401 for wrong OTP', () => {
      mockOtpStore['+919876543211'] = '999999';
      return request(app.getHttpServer())
        .post('/api/v1/auth/verify-otp')
        .send({ phone: '+919876543211', otp: '000000' })
        .expect(401);
    });

    it('should return isNewUser=false for returning user', async () => {
      mockOtpStore['+919876543210'] = '123456';
      return request(app.getHttpServer())
        .post('/api/v1/auth/verify-otp')
        .send({ phone: '+919876543210', otp: '123456' })
        .expect(201)
        .expect((res) => {
          expect(res.body.isNewUser).toBe(false);
        });
    });
  });

  describe('POST /api/v1/auth/refresh', () => {
    it('should return new tokens for valid refresh token', async () => {
      mockOtpStore['+910000000002'] = '123456';
      const loginRes = await request(app.getHttpServer())
        .post('/api/v1/auth/verify-otp')
        .send({ phone: '+910000000002', otp: '123456' });

      const refreshToken = loginRes.body.tokens.refreshToken;
      return request(app.getHttpServer())
        .post('/api/v1/auth/refresh')
        .send({ refreshToken })
        .expect(201)
        .expect((res) => {
          expect(res.body.accessToken).toBeDefined();
        });
    });

    it('should return 401 for invalid refresh token', () => {
      return request(app.getHttpServer())
        .post('/api/v1/auth/refresh')
        .send({ refreshToken: 'totally-invalid-token' })
        .expect(401);
    });
  });

  // ── Steps Routes ─────────────────────────────────────────────────────────
  describe('GET /api/v1/steps/today', () => {
    it('should return today step summary with progress', () => {
      return request(app.getHttpServer())
        .get('/api/v1/steps/today')
        .set('x-user-id', 'user-steps-1')
        .expect(200)
        .expect((res) => {
          expect(res.body.stepCount).toBe(8500);
          expect(res.body.progress).toBe(85); // 8500/10000 * 100
          expect(res.body.goalReached).toBe(false);
        });
    });

    it('should return progress=100 when goal is reached or exceeded', () => {
      mockStepsDb['user-goal-reached'] = { stepCount: 12000, caloriesBurned: 480, distanceKm: 9.1, activeMinutes: 109, goal: 10000 };
      return request(app.getHttpServer())
        .get('/api/v1/steps/today')
        .set('x-user-id', 'user-goal-reached')
        .expect(200)
        .expect((res) => {
          expect(res.body.progress).toBe(100);
          expect(res.body.goalReached).toBe(true);
        });
    });
  });

  describe('GET /api/v1/steps/history', () => {
    it('should return paginated step history', () => {
      return request(app.getHttpServer())
        .get('/api/v1/steps/history')
        .expect(200)
        .expect((res) => {
          expect(res.body.data).toBeDefined();
          expect(res.body.pagination).toBeDefined();
          expect(res.body.pagination.totalPages).toBeGreaterThanOrEqual(1);
        });
    });
  });

  describe('GET /api/v1/steps/weekly', () => {
    it('should return weekly summary with total and averages', () => {
      return request(app.getHttpServer())
        .get('/api/v1/steps/weekly')
        .expect(200)
        .expect((res) => {
          expect(res.body.totalSteps).toBeDefined();
          expect(res.body.averageSteps).toBeDefined();
          expect(res.body.activeDays).toBeDefined();
        });
    });
  });

  // ── Rewards Routes ────────────────────────────────────────────────────────
  describe('GET /api/v1/rewards/wallet', () => {
    it('should return wallet balance and lifetime points', () => {
      return request(app.getHttpServer())
        .get('/api/v1/rewards/wallet')
        .expect(200)
        .expect((res) => {
          expect(res.body.balance).toBeDefined();
          expect(res.body.lifetimePoints).toBeDefined();
          expect(typeof res.body.balance).toBe('number');
        });
    });
  });

  describe('GET /api/v1/rewards/catalog', () => {
    it('should return array of rewards with canAfford and inStock flags', () => {
      return request(app.getHttpServer())
        .get('/api/v1/rewards/catalog')
        .expect(200)
        .expect((res) => {
          expect(Array.isArray(res.body)).toBe(true);
          expect(res.body[0]).toHaveProperty('canAfford');
          expect(res.body[0]).toHaveProperty('inStock');
          expect(res.body[0]).toHaveProperty('coinCost');
        });
    });
  });

  describe('GET /api/v1/rewards/streak', () => {
    it('should return streak details with nextMilestone', () => {
      return request(app.getHttpServer())
        .get('/api/v1/rewards/streak')
        .expect(200)
        .expect((res) => {
          expect(res.body.currentStreak).toBeDefined();
          expect(res.body.longestStreak).toBeDefined();
          expect(res.body.nextMilestone).toBeDefined();
        });
    });
  });
});
