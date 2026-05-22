import { ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { AdminApiKeyGuard } from './admin-api-key.guard';

describe('AdminApiKeyGuard', () => {
  let guard: AdminApiKeyGuard;

  beforeEach(() => {
    guard = new AdminApiKeyGuard();
    process.env.ADMIN_API_KEY = 'test-key';
  });

  const createMockContext = (apiKey?: string): ExecutionContext => {
    return {
      switchToHttp: () => ({
        getRequest: () => ({
          headers: {
            'x-admin-api-key': apiKey,
          },
          ip: '127.0.0.1',
        }),
      }),
    } as any;
  };

  it('should be defined', () => {
    expect(guard).toBeDefined();
  });

  it('should throw if no api key provided', () => {
    const context = createMockContext();
    expect(() => guard.canActivate(context)).toThrow(UnauthorizedException);
    expect(() => guard.canActivate(context)).toThrow('Missing Admin API Key');
  });

  it('should throw if invalid api key', () => {
    const context = createMockContext('wrong-key');
    expect(() => guard.canActivate(context)).toThrow(UnauthorizedException);
    expect(() => guard.canActivate(context)).toThrow('Invalid Admin API Key');
  });

  it('should allow if correct api key', () => {
    const context = createMockContext('test-key');
    expect(guard.canActivate(context)).toBe(true);
  });

  it('should use fallback key if env not set', () => {
    delete process.env.ADMIN_API_KEY;
    const context = createMockContext('fallback-secret-admin-key-2026');
    expect(guard.canActivate(context)).toBe(true);
  });
});
