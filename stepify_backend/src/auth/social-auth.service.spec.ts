import { Test, TestingModule } from '@nestjs/testing';
import { SocialAuthService } from './social-auth.service';
import * as admin from 'firebase-admin';
import { UnauthorizedException } from '@nestjs/common';

jest.mock('firebase-admin', () => {
  const initializeAppMock = jest.fn();
  const credentialCertMock = jest.fn();
  const credentialAppDefaultMock = jest.fn();
  const verifyIdTokenMock = jest.fn();
  
  return {
    apps: [],
    initializeApp: initializeAppMock,
    credential: {
      cert: credentialCertMock,
      applicationDefault: credentialAppDefaultMock,
    },
    auth: jest.fn(() => ({
      verifyIdToken: verifyIdTokenMock,
    })),
  };
});

describe('SocialAuthService', () => {
  let service: SocialAuthService;
  
  const OLD_ENV = process.env;

  beforeEach(async () => {
    jest.clearAllMocks();
    jest.resetModules(); // most important - it clears the cache
    process.env = { ...OLD_ENV }; // make a copy
    
    // Reset admin.apps array mock
    (admin.apps as any) = [];

    const module: TestingModule = await Test.createTestingModule({
      providers: [SocialAuthService],
    }).compile();

    service = module.get<SocialAuthService>(SocialAuthService);
  });
  
  afterAll(() => {
    process.env = OLD_ENV; // restore old env
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('onModuleInit', () => {
    it('should initialize with env vars if present', () => {
      process.env.FIREBASE_PROJECT_ID = 'test-id';
      process.env.FIREBASE_CLIENT_EMAIL = 'test@email.com';
      process.env.FIREBASE_PRIVATE_KEY = 'test-key\\nline2';
      
      const loggerSpy = jest.spyOn((service as any).logger, 'log').mockImplementation();
      
      service.onModuleInit();
      
      expect(admin.credential.cert).toHaveBeenCalledWith({
        projectId: 'test-id',
        clientEmail: 'test@email.com',
        privateKey: 'test-key\nline2',
      });
      expect(admin.initializeApp).toHaveBeenCalled();
      expect(loggerSpy).toHaveBeenCalledWith('Firebase Admin Initialized with Env Vars');
    });

    it('should initialize with default credentials if env vars are missing', () => {
      delete process.env.FIREBASE_PROJECT_ID;
      
      const loggerSpy = jest.spyOn((service as any).logger, 'log').mockImplementation();
      
      service.onModuleInit();
      
      expect(admin.credential.applicationDefault).toHaveBeenCalled();
      expect(admin.initializeApp).toHaveBeenCalled();
      expect(loggerSpy).toHaveBeenCalledWith('Firebase Admin Initialized with Default Credentials');
    });

    it('should not initialize if admin.apps.length > 0', () => {
      (admin.apps as any) = ['app'];
      
      service.onModuleInit();
      
      expect(admin.initializeApp).not.toHaveBeenCalled();
    });

    it('should catch error and log warning if initialization fails', () => {
      delete process.env.FIREBASE_PROJECT_ID;
      const testError = new Error('Init failed');
      (admin.initializeApp as jest.Mock).mockImplementationOnce(() => {
        throw testError;
      });
      
      const loggerSpy = jest.spyOn((service as any).logger, 'warn').mockImplementation();
      
      service.onModuleInit();
      
      expect(loggerSpy).toHaveBeenCalledWith('Failed to initialize Firebase Admin. Social Login will fail.', testError);
    });
  });

  describe('verifyIdToken', () => {
    it('should return decoded token successfully', async () => {
      const mockToken = { uid: '123' };
      const authMock = admin.auth() as any;
      authMock.verifyIdToken.mockResolvedValueOnce(mockToken);
      
      const result = await service.verifyIdToken('valid-token');
      
      expect(result).toEqual(mockToken);
      expect(authMock.verifyIdToken).toHaveBeenCalledWith('valid-token');
    });

    it('should throw UnauthorizedException if verification fails', async () => {
      const authMock = admin.auth() as any;
      authMock.verifyIdToken.mockRejectedValueOnce(new Error('Invalid token'));
      
      await expect(service.verifyIdToken('invalid-token')).rejects.toThrow(UnauthorizedException);
    });
  });
});
