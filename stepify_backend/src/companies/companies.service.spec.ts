import { Test, TestingModule } from '@nestjs/testing';
import { CompaniesService } from './companies.service';
import { PrismaService } from '../prisma/prisma.service';
import { NotFoundException, BadRequestException } from '@nestjs/common';

describe('CompaniesService', () => {
  let service: CompaniesService;
  let prisma: PrismaService;

  const mockPrisma: any = {
    company: {
      create: jest.fn(),
      findMany: jest.fn(),
      findUnique: jest.fn(),
    },
    companyMember: {
      findUnique: jest.fn(),
      create: jest.fn(),
      findMany: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        CompaniesService,
        { provide: PrismaService, useValue: mockPrisma },
      ],
    }).compile();

    service = module.get<CompaniesService>(CompaniesService);
    prisma = module.get<PrismaService>(PrismaService);
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  it('should create company', async () => {
    mockPrisma.company.create.mockResolvedValueOnce({ id: 'c1' });
    const res = await service.createCompany({ name: 'C' } as any);
    expect(res.id).toBe('c1');
  });

  it('should find all companies', async () => {
    mockPrisma.company.findMany.mockResolvedValueOnce([{ id: 'c1' }]);
    const res = await service.findAll();
    expect(res).toHaveLength(1);
  });

  describe('joinCompany', () => {
    it('should throw if invalid code', async () => {
      mockPrisma.company.findUnique.mockResolvedValueOnce(null);
      await expect(service.joinCompany('BAD', 'u1')).rejects.toThrow(NotFoundException);
    });

    it('should return existing membership if already in THIS company', async () => {
      mockPrisma.company.findUnique.mockResolvedValueOnce({ id: 'c1' });
      mockPrisma.companyMember.findUnique.mockResolvedValueOnce({ companyId: 'c1' });
      const res = await service.joinCompany('CODE', 'u1');
      expect(res.companyId).toBe('c1');
    });

    it('should throw if user is in ANOTHER company', async () => {
      mockPrisma.company.findUnique.mockResolvedValueOnce({ id: 'c1' });
      mockPrisma.companyMember.findUnique.mockResolvedValueOnce({ companyId: 'c2' });
      await expect(service.joinCompany('CODE', 'u1')).rejects.toThrow(BadRequestException);
    });

    it('should create new membership', async () => {
      mockPrisma.company.findUnique.mockResolvedValueOnce({ id: 'c1' });
      mockPrisma.companyMember.findUnique.mockResolvedValueOnce(null);
      mockPrisma.companyMember.create.mockResolvedValueOnce({ companyId: 'c1' });
      const res = await service.joinCompany('CODE', 'u1');
      expect(res.companyId).toBe('c1');
    });
  });

  it('should get company leaderboard', async () => {
    mockPrisma.companyMember.findMany.mockResolvedValueOnce([{ id: 'm1' }]);
    const res = await service.getCompanyLeaderboard('c1');
    expect(res).toHaveLength(1);
  });

  it('should get user company', async () => {
    mockPrisma.companyMember.findUnique.mockResolvedValueOnce({ id: 'm1' });
    const res = await service.getUserCompany("u1");
    expect(res?.id).toBe("m1");
    expect(mockPrisma.companyMember.findUnique).toHaveBeenCalled();
  });
});
