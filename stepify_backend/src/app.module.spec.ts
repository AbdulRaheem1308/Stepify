import { Test } from '@nestjs/testing';
import { AppModule } from './app.module';
import { ConfigModule, ConfigService } from '@nestjs/config';

jest.mock('@nestjs/bullmq', () => ({
  BullModule: {
    forRootAsync: jest.fn().mockImplementation((options) => {
      // Export the useFactory so we can test it directly
      (global as any).__bullUseFactory = options.useFactory;
      return { module: class BullModuleMock {} };
    }),
  },
}));

describe('AppModule', () => {
  it('should compile the module', async () => {
    const module = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    expect(module).toBeDefined();
  });

  describe('BullModule Factory', () => {
    let configService: ConfigService;

    beforeEach(() => {
      configService = new ConfigService();
    });

    it('should use REDIS_URL and parse it correctly (rediss)', () => {
      jest.spyOn(configService, 'get').mockReturnValue('rediss://:mypass@myhost.com:1234');
      const useFactory = (global as any).__bullUseFactory;
      const res = useFactory(configService);
      expect(res.connection.host).toBe('myhost.com');
      expect(res.connection.port).toBe(1234);
      expect(res.connection.password).toBe('mypass');
      expect(res.connection.tls).toEqual({});
    });

    it('should use REDIS_URL and handle default port/no password (redis)', () => {
      jest.spyOn(configService, 'get').mockReturnValue('redis://myhost.com');
      const useFactory = (global as any).__bullUseFactory;
      const res = useFactory(configService);
      expect(res.connection.host).toBe('myhost.com');
      expect(res.connection.port).toBe(6379);
      expect(res.connection.password).toBeUndefined();
      expect(res.connection.tls).toBeUndefined();
    });

    it('should fallback to host/port on invalid REDIS_URL', () => {
      jest.spyOn(configService, 'get').mockImplementation((key) => {
        if (key === 'REDIS_URL') return 'not-a-url';
        if (key === 'REDIS_HOST') return 'fallback-host';
        if (key === 'REDIS_PORT') return 9999;
        return undefined;
      });
      const useFactory = (global as any).__bullUseFactory;
      const res = useFactory(configService);
      expect(res.connection.host).toBe('fallback-host');
      expect(res.connection.port).toBe(9999);
    });

    it('should fallback to host/port if REDIS_URL is not set', () => {
      jest.spyOn(configService, 'get').mockImplementation((key) => {
        if (key === 'REDIS_URL') return undefined;
        if (key === 'REDIS_HOST') return 'fallback-host';
        if (key === 'REDIS_PORT') return 9999;
        return undefined;
      });
      const useFactory = (global as any).__bullUseFactory;
      const res = useFactory(configService);
      expect(res.connection.host).toBe('fallback-host');
      expect(res.connection.port).toBe(9999);
    });
  });
});
