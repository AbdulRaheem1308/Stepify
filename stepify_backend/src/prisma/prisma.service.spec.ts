import { Test, TestingModule } from '@nestjs/testing';
import { PrismaService } from './prisma.service';

describe('PrismaService', () => {
  let service: PrismaService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [PrismaService],
    }).compile();

    service = module.get<PrismaService>(PrismaService);

    // Mock Prisma methods
    service.$connect = jest.fn().mockResolvedValue(undefined);
    service.$disconnect = jest.fn().mockResolvedValue(undefined);
    service.$on = jest.fn();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should connect to database on module init', async () => {
    await service.onModuleInit();
    expect(service.$connect).toHaveBeenCalled();
    expect(service.$on).toHaveBeenCalledWith('query', expect.any(Function));
  });

  it('should disconnect from database on module destroy', async () => {
    await service.onModuleDestroy();
    expect(service.$disconnect).toHaveBeenCalled();
  });

  it('should log slow queries', async () => {
    await service.onModuleInit();
    
    const onCall = (service.$on as jest.Mock).mock.calls.find(call => call[0] === 'query');
    expect(onCall).toBeDefined();
    
    const queryHandler = onCall[1];
    
    const loggerSpy = jest.spyOn((service as any).logger, 'warn').mockImplementation();
    
    // Fast query (no log)
    queryHandler({ duration: 100, query: 'SELECT 1' });
    expect(loggerSpy).not.toHaveBeenCalled();

    // Slow query (log)
    queryHandler({ duration: 300, query: 'SELECT * FROM huge_table' });
    expect(loggerSpy).toHaveBeenCalledWith('Slow Query [300ms]: SELECT * FROM huge_table');
  });
});
