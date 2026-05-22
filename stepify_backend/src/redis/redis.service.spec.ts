import { Test, TestingModule } from '@nestjs/testing';
import { RedisService } from './redis.service';
import { ConfigService } from '@nestjs/config';

jest.mock('ioredis', () => {
  const mRedis = jest.fn().mockImplementation(() => {
    return {
      on: jest.fn(),
      quit: jest.fn().mockResolvedValue('OK'),
      status: 'ready',
      setex: jest.fn().mockResolvedValue('OK'),
      get: jest.fn(),
      del: jest.fn().mockResolvedValue(1),
      incr: jest.fn(),
      expire: jest.fn().mockResolvedValue(1),
      exists: jest.fn(),
      ttl: jest.fn(),
      set: jest.fn().mockResolvedValue('OK'),
    };
  });
  return {
    __esModule: true,
    default: mRedis,
    Redis: mRedis,
  };
});

describe('RedisService', () => {
  let service: RedisService;
  let mockClient: any;

  beforeEach(async () => {
    jest.clearAllMocks();
    
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        RedisService,
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn((key) => {
              if (key === 'NODE_ENV') return 'test';
              if (key === 'REDIS_URL') return 'redis://localhost:6379';
              return null;
            }),
          },
        },
      ],
    }).compile();

    service = module.get<RedisService>(RedisService);
    mockClient = service.getClient();
    Object.defineProperty(mockClient, 'status', { value: 'ready', writable: true });
  });

  afterEach(async () => {
    await service.onModuleDestroy();
  });

  describe('onModuleDestroy', () => {
    it('should call quit on redis client and clear interval', async () => {
      await service.onModuleDestroy();
      expect(mockClient.quit).toHaveBeenCalled();
    });
  });

  describe('OTP Management', () => {
    it('should set OTP with expiry', async () => {
      await service.setOtp('test@test.com', '123456', 5);
      expect(mockClient.setex).toHaveBeenCalledWith('otp:test@test.com', 300, '123456');
    });

    it('should fallback to memory store if redis is not connected for setOtp', async () => {
      mockClient.status = 'connecting';
      await service.setOtp('mem@test.com', '654321', 5);
      expect(mockClient.setex).not.toHaveBeenCalled();
      const otp = await service.getOtp('mem@test.com');
      expect(otp).toBe('654321');
    });

    it('should get OTP from redis', async () => {
      mockClient.get.mockResolvedValue('123456');
      const otp = await service.getOtp('test@test.com');
      expect(otp).toBe('123456');
      expect(mockClient.get).toHaveBeenCalledWith('otp:test@test.com');
    });

    it('should return null from memory store if expired', async () => {
      mockClient.status = 'connecting';
      await service.setOtp('mem@test.com', '654321', -1);
      const otp = await service.getOtp('mem@test.com');
      expect(otp).toBeNull();
    });

    it('should delete OTP from redis', async () => {
      await service.deleteOtp('test@test.com');
      expect(mockClient.del).toHaveBeenCalledWith('otp:test@test.com');
    });

    it('should delete OTP from memory store', async () => {
      mockClient.status = 'connecting';
      await service.setOtp('mem@test.com', '654321', 5);
      await service.deleteOtp('mem@test.com');
      const otp = await service.getOtp('mem@test.com');
      expect(otp).toBeNull();
    });
  });

  describe('Rate Limiting', () => {
    it('should allow if count <= 5', async () => {
      mockClient.incr.mockResolvedValue(1);
      const res = await service.checkOtpRateLimit('test');
      expect(mockClient.expire).toHaveBeenCalledWith('otp_rate:test', 3600);
      expect(res).toBe(true);
    });

    it('should fail if count > 5', async () => {
      mockClient.incr.mockResolvedValue(6);
      const res = await service.checkOtpRateLimit('test');
      expect(res).toBe(false);
    });

    it('should fail open if redis is not connected', async () => {
      mockClient.status = 'connecting';
      const res = await service.checkOtpRateLimit('test');
      expect(res).toBe(true);
    });
    
    it('should fail open if redis throws', async () => {
      mockClient.incr.mockRejectedValue(new Error('error'));
      const res = await service.checkOtpRateLimit('test');
      expect(res).toBe(true);
    });
  });

  describe('Ad Cooldown', () => {
    it('should return true if no cooldown', async () => {
      mockClient.exists.mockResolvedValue(0);
      const res = await service.checkAdCooldown('u1');
      expect(res).toBe(true);
    });

    it('should set cooldown', async () => {
      await service.setAdCooldown('u1', 5);
      expect(mockClient.setex).toHaveBeenCalledWith('ad_cooldown:u1', 300, '1');
    });

    it('should get TTL', async () => {
      mockClient.ttl.mockResolvedValue(100);
      const res = await service.getAdCooldownRemaining('u1');
      expect(res).toBe(100);
    });
  });

  describe('Cache helpers', () => {
    it('should set cache', async () => {
      await service.setCache('k1', { data: 1 }, 10);
      expect(mockClient.setex).toHaveBeenCalledWith('k1', 10, '{"data":1}');
    });

    it('should get cache', async () => {
      mockClient.get.mockResolvedValue('{"data":1}');
      const res = await service.getCache('k1');
      expect(res).toEqual({ data: 1 });
    });

    it('should delete cache', async () => {
      await service.deleteCache('k1');
      expect(mockClient.del).toHaveBeenCalledWith('k1');
    });

    it('should handle cache get errors gracefully', async () => {
      mockClient.get.mockRejectedValue(new Error('err'));
      const res = await service.getCache('k1');
      expect(res).toBeNull();
    });
  });

  describe('Nonce Check', () => {
    it('should allow new nonce', async () => {
      const res = await service.setNonce('nonce1', 10);
      expect(res).toBe(true);
      expect(mockClient.set).toHaveBeenCalledWith('nonce:nonce1', 'used', 'EX', 10, 'NX');
    });

    it('should reject existing nonce', async () => {
      mockClient.set.mockResolvedValue(null);
      const res = await service.setNonce('nonce1', 10);
      expect(res).toBe(false);
    });

    it('should use memory store if redis disconnected', async () => {
      mockClient.status = 'connecting';
      const res1 = await service.setNonce('m-nonce', 10);
      const res2 = await service.setNonce('m-nonce', 10);
      expect(res1).toBe(true);
      expect(res2).toBe(false);
    });
    
    it('should fail secure if redis throws', async () => {
      mockClient.set.mockRejectedValue(new Error('err'));
      const res = await service.setNonce('nonce1', 10);
      expect(res).toBe(false);
    });
  });
});
