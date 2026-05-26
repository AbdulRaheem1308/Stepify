import { Test, TestingModule } from '@nestjs/testing';
import { PostHogService } from './posthog.service';
import { ConfigService } from '@nestjs/config';
import { Logger } from '@nestjs/common';

describe('PostHogService', () => {
  let service: PostHogService;
  let _configService: ConfigService;
  let fetchSpy: jest.SpyInstance;
  let loggerWarnSpy: jest.SpyInstance;
  let loggerLogSpy: jest.SpyInstance;

  beforeEach(async () => {
    fetchSpy = jest.spyOn(global, 'fetch').mockImplementation(() =>
      Promise.resolve({
        ok: true,
        status: 200,
        json: () => Promise.resolve({}),
      } as Response)
    );

    loggerWarnSpy = jest.spyOn(Logger.prototype, 'warn').mockImplementation(() => {});
    loggerLogSpy = jest.spyOn(Logger.prototype, 'log').mockImplementation(() => {});

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PostHogService,
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn((key: string, defaultValue: any) => {
              if (key === 'POSTHOG_API_KEY') return 'test-api-key';
              if (key === 'POSTHOG_HOST') return 'https://test.posthog.com';
              return defaultValue;
            }),
          },
        },
      ],
    }).compile();

    service = module.get<PostHogService>(PostHogService);
    _configService = module.get<ConfigService>(ConfigService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('initialization', () => {
    it('should be defined and enabled if API key is present', () => {
      expect(service).toBeDefined();
      expect(loggerLogSpy).toHaveBeenCalledWith(expect.stringContaining('PostHog analytics enabled'));
    });

    it('should be disabled if API key is absent', async () => {
      const emptyConfigModule: TestingModule = await Test.createTestingModule({
        providers: [
          PostHogService,
          {
            provide: ConfigService,
            useValue: {
              get: jest.fn((key: string) => {
                if (key === 'POSTHOG_API_KEY') return '';
                return null;
              }),
            },
          },
        ],
      }).compile();

      const emptyService = emptyConfigModule.get<PostHogService>(PostHogService);
      expect(loggerWarnSpy).toHaveBeenCalledWith(expect.stringContaining('PostHog API key not set'));
      
      // Attempting to capture should return early without fetching
      await emptyService.capture('user1', 'test_event');
      expect(fetchSpy).not.toHaveBeenCalled();
    });
  });

  describe('capture', () => {
    it('should successfully capture an event via fetch', async () => {
      await service.capture('user1', 'test_event', { customProp: true });
      expect(fetchSpy).toHaveBeenCalledTimes(1);
      
      const fetchArgs = fetchSpy.mock.calls[0];
      expect(fetchArgs[0]).toBe('https://test.posthog.com/capture/');
      expect(fetchArgs[1].method).toBe('POST');
      
      const body = JSON.parse(fetchArgs[1].body);
      expect(body.api_key).toBe('test-api-key');
      expect(body.distinct_id).toBe('user1');
      expect(body.event).toBe('test_event');
      expect(body.properties.customProp).toBe(true);
      expect(body.properties.$lib).toBe('stepify-backend');
    });

    it('should log a warning if fetch responds with not ok', async () => {
      fetchSpy.mockResolvedValueOnce({
        ok: false,
        status: 400,
      } as Response);

      await service.capture('user1', 'test_event');
      expect(loggerWarnSpy).toHaveBeenCalledWith(expect.stringContaining('HTTP 400'));
    });

    it('should log a warning if fetch throws an error (e.g. timeout)', async () => {
      fetchSpy.mockRejectedValueOnce(new Error('Network error'));

      await service.capture('user1', 'test_event');
      expect(loggerWarnSpy).toHaveBeenCalledWith(expect.stringContaining('Network error'));
    });
  });

  describe('helpers', () => {
    it('should track trackStepSync', async () => {
      const captureSpy = jest.spyOn(service, 'capture').mockResolvedValue();
      await service.trackStepSync('u1', 1000, 'apple_health');
      expect(captureSpy).toHaveBeenCalledWith('u1', 'steps_synced', { step_count: 1000, source: 'apple_health' });
    });

    it('should identify user', async () => {
      const captureSpy = jest.spyOn(service, 'capture').mockResolvedValue();
      await service.identify('u1', { name: 'Raheem' });
      expect(captureSpy).toHaveBeenCalledWith('u1', '$identify', { $set: { name: 'Raheem' } });
    });

    it('should track trackChallengeJoined', async () => {
      const captureSpy = jest.spyOn(service, 'capture').mockResolvedValue();
      await service.trackChallengeJoined('u1', 'c1', 'Summer Step');
      expect(captureSpy).toHaveBeenCalledWith('u1', 'challenge_joined', { challenge_id: 'c1', challenge_title: 'Summer Step' });
    });

    it('should track trackRewardRedeemed', async () => {
      const captureSpy = jest.spyOn(service, 'capture').mockResolvedValue();
      await service.trackRewardRedeemed('u1', 'r1', 500);
      expect(captureSpy).toHaveBeenCalledWith('u1', 'reward_redeemed', { reward_id: 'r1', coin_cost: 500 });
    });

    it('should track trackAdWatched', async () => {
      const captureSpy = jest.spyOn(service, 'capture').mockResolvedValue();
      await service.trackAdWatched('u1', 'video', 10);
      expect(captureSpy).toHaveBeenCalledWith('u1', 'ad_watched', { ad_type: 'video', points_earned: 10 });
    });

    it('should track trackUserLogin', async () => {
      const captureSpy = jest.spyOn(service, 'capture').mockResolvedValue();
      await service.trackUserLogin('u1', 'google');
      expect(captureSpy).toHaveBeenCalledWith('u1', 'user_logged_in', { method: 'google' });
    });

    it('should track trackAchievementUnlocked', async () => {
      const captureSpy = jest.spyOn(service, 'capture').mockResolvedValue();
      await service.trackAchievementUnlocked('u1', 'ACH_1', 'Milestone');
      expect(captureSpy).toHaveBeenCalledWith('u1', 'achievement_unlocked', { achievement_code: 'ACH_1', category: 'Milestone' });
    });
  });
});
