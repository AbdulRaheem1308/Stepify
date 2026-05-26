import { Test, TestingModule } from '@nestjs/testing';
import { QuestsController } from './quests.controller';
import { QuestsService } from './quests.service';
import { ForbiddenException } from '@nestjs/common';

describe('QuestsController', () => {
  let controller: QuestsController;
  let service: QuestsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [QuestsController],
      providers: [
        {
          provide: QuestsService,
          useValue: {
            findAll: jest.fn(),
            joinQuest: jest.fn(),
            getUserQuests: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<QuestsController>(QuestsController);
    service = module.get<QuestsService>(QuestsService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('findAll', () => {
    it('should return all quests', async () => {
      await controller.findAll();
      expect(service.findAll).toHaveBeenCalled();
    });
  });

  describe('joinQuest', () => {
    it('should join quest with implicit user', async () => {
      const user = { id: 'u1' };
      await controller.joinQuest('q1', {}, user);
      expect(service.joinQuest).toHaveBeenCalledWith('u1', 'q1');
    });

    it('should join quest with explicit matching user', async () => {
      const user = { id: 'u1' };
      await controller.joinQuest('q1', { userId: 'u1' }, user);
      expect(service.joinQuest).toHaveBeenCalledWith('u1', 'q1');
    });

    it('should throw forbidden if userId mismatch', async () => {
      const user = { id: 'u1' };
      await expect(controller.joinQuest('q1', { userId: 'u2' }, user)).rejects.toThrow(ForbiddenException);
    });
  });

  describe('getOwnQuests', () => {
    it('should get own quests', async () => {
      const user = { id: 'u1' };
      await controller.getOwnQuests(user);
      expect(service.getUserQuests).toHaveBeenCalledWith('u1');
    });
  });

  describe('getMyQuests', () => {
    it('should get quests for me', async () => {
      const user = { id: 'u1' };
      await controller.getMyQuests('me', user);
      expect(service.getUserQuests).toHaveBeenCalledWith('u1');
    });

    it('should get quests for matching userId', async () => {
      const user = { id: 'u1' };
      await controller.getMyQuests('u1', user);
      expect(service.getUserQuests).toHaveBeenCalledWith('u1');
    });

    it('should throw forbidden if userId mismatch', async () => {
      const user = { id: 'u1' };
      await expect(controller.getMyQuests('u2', user)).rejects.toThrow(ForbiddenException);
    });
  });
});
