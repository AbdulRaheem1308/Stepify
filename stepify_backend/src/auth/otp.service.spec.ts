import { Test, TestingModule } from '@nestjs/testing';
import { OtpService } from './otp.service';
import { ConfigService } from '@nestjs/config';

jest.mock('twilio', () => {
  return jest.fn().mockImplementation(() => {
    return {
      messages: {
        create: jest.fn().mockResolvedValue({ sid: 'test-sid' }),
      },
    };
  });
});

describe('OtpService', () => {
  let service: OtpService;
  let mockConfigService: any;
  let loggerLogSpy: jest.SpyInstance;
  let loggerWarnSpy: jest.SpyInstance;

  beforeEach(async () => {
    jest.clearAllMocks();

    mockConfigService = {
      get: jest.fn((key) => {
        if (key === 'NODE_ENV') return 'development';
        if (key === 'OTP_LENGTH') return 6;
        return null;
      }),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        OtpService,
        { provide: ConfigService, useValue: mockConfigService },
      ],
    }).compile();

    service = module.get<OtpService>(OtpService);
    
    loggerLogSpy = jest.spyOn((service as any).logger, 'log').mockImplementation();
    loggerWarnSpy = jest.spyOn((service as any).logger, 'warn').mockImplementation();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('Initialization', () => {
    it('should initialize without twilio if missing config', () => {
      expect((service as any).twilioClient).toBeNull();
      expect(loggerWarnSpy).toHaveBeenCalledWith('Twilio not configured - OTPs will be logged to console');
    });

    it('should log critical error in production if twilio missing', async () => {
      mockConfigService.get.mockImplementation((k: string) => k === 'NODE_ENV' ? 'production' : null);
      
      const module: TestingModule = await Test.createTestingModule({
        providers: [OtpService, { provide: ConfigService, useValue: mockConfigService }],
      }).compile();

      const prodService = module.get<OtpService>(OtpService);
      const prodErrorSpy = jest.spyOn((prodService as any).logger, 'error').mockImplementation();
      
      // Need to re-instantiate or check constructor logic.
      // NestJS will create a new instance when we get it from module.
      expect(prodErrorSpy).toHaveBeenCalledWith('CRITICAL: Twilio credentials missing or invalid in PRODUCTION mode! SMS OTPs will fail.');
    });

    it('should initialize twilio if config is valid', async () => {
      mockConfigService.get.mockImplementation((k: string) => {
        if (k === 'TWILIO_ACCOUNT_SID') return 'valid-sid';
        if (k === 'TWILIO_AUTH_TOKEN') return 'valid-token';
        return null;
      });
      
      const module: TestingModule = await Test.createTestingModule({
        providers: [OtpService, { provide: ConfigService, useValue: mockConfigService }],
      }).compile();

      const validService = module.get<OtpService>(OtpService);
      expect((validService as any).twilioClient).not.toBeNull();
    });
  });

  describe('generateOtp', () => {
    it('should generate a 6 digit otp by default', () => {
      const otp = service.generateOtp();
      expect(otp).toHaveLength(6);
      expect(Number(otp)).not.toBeNaN();
    });

    it('should respect OTP_LENGTH config', async () => {
      mockConfigService.get.mockImplementation((k: string) => {
        if (k === 'OTP_LENGTH') return 4;
        return null;
      });
      
      const module: TestingModule = await Test.createTestingModule({
        providers: [OtpService, { provide: ConfigService, useValue: mockConfigService }],
      }).compile();

      const lengthService = module.get<OtpService>(OtpService);
      const otp = lengthService.generateOtp();
      expect(otp).toHaveLength(4);
    });
  });

  describe('sendSmsOtp', () => {
    it('should use twilio if client initialized', async () => {
      mockConfigService.get.mockImplementation((k: string) => {
        if (k === 'TWILIO_ACCOUNT_SID') return 'valid-sid';
        if (k === 'TWILIO_AUTH_TOKEN') return 'valid-token';
        if (k === 'TWILIO_PHONE_NUMBER') return '123456';
        return null;
      });
      
      const module: TestingModule = await Test.createTestingModule({
        providers: [OtpService, { provide: ConfigService, useValue: mockConfigService }],
      }).compile();

      const validService = module.get<OtpService>(OtpService);
      const validLoggerSpy = jest.spyOn((validService as any).logger, 'log').mockImplementation();
      
      await validService.sendSmsOtp('phone1', '123456');
      
      const twilioClient = (validService as any).twilioClient;
      expect(twilioClient.messages.create).toHaveBeenCalledWith({
        body: 'Your Stepify verification code is: 123456. Valid for 5 minutes.',
        from: '123456',
        to: 'phone1',
      });
      expect(validLoggerSpy).toHaveBeenCalledWith('OTP sent to phone1');
    });

    it('should fallback to dev log if twilio fails to send', async () => {
      mockConfigService.get.mockImplementation((k: string) => {
        if (k === 'TWILIO_ACCOUNT_SID') return 'valid-sid';
        if (k === 'TWILIO_AUTH_TOKEN') return 'valid-token';
        return null;
      });
      
      const module: TestingModule = await Test.createTestingModule({
        providers: [OtpService, { provide: ConfigService, useValue: mockConfigService }],
      }).compile();

      const validService = module.get<OtpService>(OtpService);
      const validErrorSpy = jest.spyOn((validService as any).logger, 'error').mockImplementation();
      const validLogSpy = jest.spyOn((validService as any).logger, 'log').mockImplementation();
      
      const twilioClient = (validService as any).twilioClient;
      twilioClient.messages.create.mockRejectedValueOnce(new Error('Twilio error'));
      
      await validService.sendSmsOtp('phone2', '111111');
      
      expect(validErrorSpy).toHaveBeenCalledWith('Failed to send SMS to phone2:', 'Twilio error');
      expect(validLogSpy).toHaveBeenCalledWith('Code: 111111');
    });

    it('should log to console if no twilio client', async () => {
      await service.sendSmsOtp('phone3', '222222');
      expect(loggerLogSpy).toHaveBeenCalledWith('Code: 222222');
    });
  });

  describe('sendEmailOtp', () => {
    it('should log email OTP to console', async () => {
      await service.sendEmailOtp('test@test.com', '555555');
      expect(loggerLogSpy).toHaveBeenCalledWith('Code: 555555');
      expect(loggerLogSpy).toHaveBeenCalledWith('EMAIL OTP for test@test.com');
    });
  });
});
