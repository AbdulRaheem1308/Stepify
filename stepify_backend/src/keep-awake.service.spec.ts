import { Test, TestingModule } from '@nestjs/testing';
import { KeepAwakeService } from './keep-awake.service';

describe('KeepAwakeService', () => {
  let service: KeepAwakeService;
  let originalFetch: typeof fetch;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [KeepAwakeService],
    }).compile();

    service = module.get<KeepAwakeService>(KeepAwakeService);
    originalFetch = global.fetch;
  });

  afterEach(() => {
    global.fetch = originalFetch;
    delete process.env.RENDER_EXTERNAL_URL;
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should skip pinging if RENDER_EXTERNAL_URL is not set', async () => {
    const mockFetch = jest.fn();
    global.fetch = mockFetch;

    await service.handleCron();
    expect(mockFetch).not.toHaveBeenCalled();
  });

  it('should ping the health endpoint if RENDER_EXTERNAL_URL is set', async () => {
    process.env.RENDER_EXTERNAL_URL = 'https://my-render-app.com';
    const mockFetch = jest.fn().mockResolvedValue({
      ok: true,
      status: 200,
      statusText: 'OK',
    } as any);
    global.fetch = mockFetch;

    await service.handleCron();
    expect(mockFetch).toHaveBeenCalledWith('https://my-render-app.com/api/v1/health');
  });

  it('should log an error if ping fails with non-ok status', async () => {
    process.env.RENDER_EXTERNAL_URL = 'https://my-render-app.com';
    const mockFetch = jest.fn().mockResolvedValue({
      ok: false,
      status: 500,
    } as any);
    global.fetch = mockFetch;

    await service.handleCron();
    expect(mockFetch).toHaveBeenCalledWith('https://my-render-app.com/api/v1/health');
  });

  it('should log an error if fetch throws an exception', async () => {
    process.env.RENDER_EXTERNAL_URL = 'https://my-render-app.com';
    const mockFetch = jest.fn().mockRejectedValue(new Error('Network error'));
    global.fetch = mockFetch;

    await service.handleCron();
    expect(mockFetch).toHaveBeenCalledWith('https://my-render-app.com/api/v1/health');
  });
  
  it('should log an error if fetch throws a non-error exception', async () => {
    process.env.RENDER_EXTERNAL_URL = 'https://my-render-app.com';
    const mockFetch = jest.fn().mockRejectedValue('String error');
    global.fetch = mockFetch;

    await service.handleCron();
    expect(mockFetch).toHaveBeenCalledWith('https://my-render-app.com/api/v1/health');
  });
});
