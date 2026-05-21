import { Test, TestingModule } from '@nestjs/testing';
import { Controller, Get, INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import helmet from 'helmet';
import { ThrottlerModule, ThrottlerGuard } from '@nestjs/throttler';
import { APP_GUARD } from '@nestjs/core';

@Controller('health')
class MockHealthController {
  @Get()
  check() {
    return { status: 'ok' };
  }
}

describe('Security Hardening (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [
        ThrottlerModule.forRoot([{
          ttl: 60000,
          limit: 100, // Same limits as production
        }]),
      ],
      controllers: [MockHealthController],
      providers: [
        {
          provide: APP_GUARD,
          useClass: ThrottlerGuard,
        },
      ],
    }).compile();

    app = moduleFixture.createNestApplication();
    
    // Apply security middleware exactly as in main.ts
    app.use(helmet());
    
    // Apply CORS exactly as in main.ts
    app.enableCors({
      origin: [
        'http://localhost:3000',
        'http://localhost:5173',
        'https://stepify.app',
        'https://admin.stepify.app',
      ],
      credentials: true,
    });
    
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  describe('Helmet Middleware (Security Headers)', () => {
    it('should set X-Frame-Options to SAMEORIGIN (clickjacking protection)', () => {
      return request(app.getHttpServer())
        .get('/health')
        .expect(200)
        .expect((res) => {
          expect(res.headers['x-frame-options']).toBe('SAMEORIGIN');
        });
    });

    it('should set Content-Security-Policy (XSS protection)', () => {
      return request(app.getHttpServer())
        .get('/health')
        .expect(200)
        .expect((res) => {
          expect(res.headers['content-security-policy']).toBeDefined();
        });
    });

    it('should remove X-Powered-By header (information leakage)', () => {
      return request(app.getHttpServer())
        .get('/health')
        .expect(200)
        .expect((res) => {
          expect(res.headers['x-powered-by']).toBeUndefined();
        });
    });
    
    it('should set X-Content-Type-Options to nosniff (MIME sniffing protection)', () => {
      return request(app.getHttpServer())
        .get('/health')
        .expect(200)
        .expect((res) => {
          expect(res.headers['x-content-type-options']).toBe('nosniff');
        });
    });
  });

  describe('CORS Restrictions', () => {
    it('should allow requests from allowed origins', () => {
      return request(app.getHttpServer())
        .get('/health')
        .set('Origin', 'https://stepify.app')
        .expect(200)
        .expect((res) => {
          expect(res.headers['access-control-allow-origin']).toBe('https://stepify.app');
        });
    });
  });

  describe('Throttler Guard (Rate Limiting - DDoS protection)', () => {
    it('should return 429 Too Many Requests when hitting limits', async () => {
      // Loop 105 times sequentially to avoid socket ECONNRESET
      let tooManyRequestsCount = 0;
      for (let i = 0; i < 105; i++) {
        const res = await request(app.getHttpServer()).get('/health');
        if (res.status === 429) {
          tooManyRequestsCount++;
        }
      }

      // Should trigger at least once
      expect(tooManyRequestsCount).toBeGreaterThanOrEqual(1);
    });
  });
});
