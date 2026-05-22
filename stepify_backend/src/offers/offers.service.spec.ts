import { Test, TestingModule } from '@nestjs/testing';
import { OffersService } from './offers.service';
import { PrismaService } from '../prisma/prisma.service';

describe('OffersService', () => {
  let service: OffersService;
  let prisma: PrismaService;

  const mockPrisma: any = {
    $transaction: jest.fn(async (cb) => cb(mockPrisma)),
    offer: {
      findMany: jest.fn(),
      create: jest.fn(),
    },
    userOffer: {
      findMany: jest.fn(),
      upsert: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
    },
    wallet: {
      upsert: jest.fn(),
    },
    transaction: {
      create: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        OffersService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();

    service = module.get<OffersService>(OffersService);
    prisma = module.get<PrismaService>(PrismaService);
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should find all active offers', async () => {
    mockPrisma.offer.findMany.mockResolvedValueOnce([{ id: 'o1' }]);
    const res = await service.findAllActive();
    expect(res).toHaveLength(1);
  });

  it('should get user offers', async () => {
    mockPrisma.userOffer.findMany.mockResolvedValueOnce([{ id: 'uo1' }]);
    const res = await service.getUserOffers('u1', 'STARTED');
    expect(res).toHaveLength(1);
    expect(mockPrisma.userOffer.findMany).toHaveBeenCalledWith(
      expect.objectContaining({ where: expect.objectContaining({ userId: 'u1', status: 'STARTED' }) })
    );
  });

  it('should start an offer', async () => {
    mockPrisma.userOffer.upsert.mockResolvedValueOnce({ id: 'uo1' });
    const res = await service.startOffer('u1', 'o1');
    expect(res.id).toBe('uo1');
  });

  describe('completeOffer', () => {
    it('should throw if not started', async () => {
      mockPrisma.userOffer.findUnique.mockResolvedValueOnce(null);
      await expect(service.completeOffer('u1', 'o1')).rejects.toThrow('Offer not found');
    });

    it('should complete offer and reward', async () => {
      mockPrisma.userOffer.findUnique.mockResolvedValueOnce({ status: 'STARTED', offer: { rewardCoins: 100 } });
      mockPrisma.userOffer.update.mockResolvedValueOnce({});
      mockPrisma.wallet.upsert.mockResolvedValueOnce({});
      mockPrisma.transaction.create.mockResolvedValueOnce({});

      const res = await service.completeOffer('u1', 'o1');
      expect(res.rewarded).toBe(100);
      expect(mockPrisma.userOffer.update).toHaveBeenCalled();
      expect(mockPrisma.wallet.upsert).toHaveBeenCalled();
    });
  });

  it('should create offer', async () => {
    mockPrisma.offer.create.mockResolvedValueOnce({ id: 'o1' });
    const res = await service.createOffer({ title: 'T' } as any);
    expect(res.id).toBe('o1');
  });
});
