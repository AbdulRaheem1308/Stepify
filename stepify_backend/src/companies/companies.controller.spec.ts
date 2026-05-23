import { Test, TestingModule } from '@nestjs/testing';
import { CompaniesController } from './companies.controller';
import { CompaniesService } from './companies.service';
import { ForbiddenException } from '@nestjs/common';

describe('CompaniesController', () => {
  let controller: CompaniesController;
  let service: CompaniesService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [CompaniesController],
      providers: [
        {
          provide: CompaniesService,
          useValue: {
            createCompany: jest.fn(),
            findAll: jest.fn(),
            joinCompany: jest.fn(),
            getCompanyLeaderboard: jest.fn(),
            getUserCompany: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<CompaniesController>(CompaniesController);
    service = module.get<CompaniesService>(CompaniesService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('create', () => {
    it('should create a company', async () => {
      const dto = { name: 'Comp A', joinCode: 'abc' } as any;
      await controller.create(dto);
      expect(service.createCompany).toHaveBeenCalledWith(dto);
    });
  });

  describe('findAll', () => {
    it('should return all companies', async () => {
      await controller.findAll();
      expect(service.findAll).toHaveBeenCalled();
    });
  });

  describe('joinCompany', () => {
    it('should join company with implicit user', async () => {
      const user = { id: 'u1' };
      await controller.joinCompany('CODE', {}, user);
      expect(service.joinCompany).toHaveBeenCalledWith('CODE', 'u1');
    });

    it('should join company with explicit matching user', async () => {
      const user = { id: 'u1' };
      await controller.joinCompany('CODE', { userId: 'u1' } as any, user);
      expect(service.joinCompany).toHaveBeenCalledWith('CODE', 'u1');
    });

    it('should throw forbidden if userId mismatch', async () => {
      const user = { id: 'u1' };
      await expect(controller.joinCompany('CODE', { userId: 'u2' } as any, user)).rejects.toThrow(ForbiddenException);
    });
  });

  describe('getLeaderboard', () => {
    it('should return leaderboard', async () => {
      await controller.getLeaderboard('c1');
      expect(service.getCompanyLeaderboard).toHaveBeenCalledWith('c1');
    });
  });

  describe('getMyCompany', () => {
    it('should get company for me', async () => {
      const user = { id: 'u1' };
      await controller.getMyCompany('me', user);
      expect(service.getUserCompany).toHaveBeenCalledWith('u1');
    });

    it('should get company for matching userId', async () => {
      const user = { id: 'u1' };
      await controller.getMyCompany('u1', user);
      expect(service.getUserCompany).toHaveBeenCalledWith('u1');
    });

    it('should throw forbidden if userId mismatch', async () => {
      const user = { id: 'u1' };
      await expect(controller.getMyCompany('u2', user)).rejects.toThrow(ForbiddenException);
    });
  });
});
