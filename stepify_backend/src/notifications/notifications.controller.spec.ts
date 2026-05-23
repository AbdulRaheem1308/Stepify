import { Test, TestingModule } from '@nestjs/testing';
import { NotificationsController } from './notifications.controller';
import { NotificationsService } from './notifications.service';

describe('NotificationsController', () => {
  let controller: NotificationsController;
  let service: NotificationsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [NotificationsController],
      providers: [
        {
          provide: NotificationsService,
          useValue: {
            getUserNotifications: jest.fn(),
            registerFcmToken: jest.fn(),
            markAsRead: jest.fn(),
            deleteNotification: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<NotificationsController>(NotificationsController);
    service = module.get<NotificationsService>(NotificationsService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('getNotifications', () => {
    it('should get notifications with limit', async () => {
      const req = { user: { sub: 'u1' } };
      await controller.getNotifications(req, 10);
      expect(service.getUserNotifications).toHaveBeenCalledWith('u1', 10);
    });

    it('should get notifications with default limit', async () => {
      const req = { user: { sub: 'u1' } };
      await controller.getNotifications(req);
      expect(service.getUserNotifications).toHaveBeenCalledWith('u1', 20);
    });
  });

  describe('registerFcmToken', () => {
    it('should register fcm token', async () => {
      const req = { user: { sub: 'u1' } };
      await controller.registerFcmToken(req, { token: 'tok1' });
      expect(service.registerFcmToken).toHaveBeenCalledWith('u1', 'tok1');
    });
  });

  describe('markAsRead', () => {
    it('should mark as read', async () => {
      const req = { user: { sub: 'u1' } };
      await controller.markAsRead(req, 'n1');
      expect(service.markAsRead).toHaveBeenCalledWith('u1', 'n1');
    });
  });

  describe('deleteNotification', () => {
    it('should delete notification', async () => {
      const req = { user: { sub: 'u1' } };
      await controller.deleteNotification(req, 'n1');
      expect(service.deleteNotification).toHaveBeenCalledWith('u1', 'n1');
    });
  });
});
