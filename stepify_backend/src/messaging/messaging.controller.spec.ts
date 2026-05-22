import { Test, TestingModule } from '@nestjs/testing';
import { MessagingController } from './messaging.controller';
import { MessagingService } from './messaging.service';
import { ForbiddenException } from '@nestjs/common';

describe('MessagingController', () => {
  let controller: MessagingController;
  let service: MessagingService;

  const mockMessagingService = {
    getConversations: jest.fn(),
    getMessages: jest.fn(),
    startConversation: jest.fn(),
    sendMessage: jest.fn(),
    isParticipant: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [MessagingController],
      providers: [
        { provide: MessagingService, useValue: mockMessagingService },
      ],
    }).compile();

    controller = module.get<MessagingController>(MessagingController);
    service = module.get<MessagingService>(MessagingService);
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('getConversations', () => {
    it('should throw if querying other user', async () => {
      await expect(controller.getConversations('u2', { id: 'u1' })).rejects.toThrow(ForbiddenException);
    });

    it('should get conversations for me', async () => {
      mockMessagingService.getConversations.mockResolvedValueOnce([{ id: 'c1' }]);
      const res = await controller.getConversations('me', { id: 'u1' });
      expect(res).toHaveLength(1);
    });
  });

  describe('getMessages', () => {
    it('should throw if not participant', async () => {
      mockMessagingService.isParticipant.mockResolvedValueOnce(false);
      await expect(controller.getMessages('c1', { id: 'u1' })).rejects.toThrow(ForbiddenException);
    });

    it('should return messages', async () => {
      mockMessagingService.isParticipant.mockResolvedValueOnce(true);
      mockMessagingService.getMessages.mockResolvedValueOnce([{ content: 'hi' }]);
      const res = await controller.getMessages('c1', { id: 'u1' });
      expect(res[0].content).toBe('hi');
    });
  });

  describe('startConversation', () => {
    it('should throw if starting as another user', async () => {
      await expect(controller.startConversation({ userId: 'u2', otherUserId: 'u3' } as any, { id: 'u1' })).rejects.toThrow(ForbiddenException);
    });

    it('should start conversation', async () => {
      mockMessagingService.startConversation.mockResolvedValueOnce({ id: 'c1' });
      const res = await controller.startConversation({ otherUserId: 'u3' } as any, { id: 'u1' });
      expect(res.id).toBe('c1');
    });
  });

  describe('sendMessage', () => {
    it('should throw if sending as another user', async () => {
      await expect(controller.sendMessage({ senderId: 'u2' } as any, { id: 'u1' })).rejects.toThrow(ForbiddenException);
    });

    it('should throw if not participant', async () => {
      mockMessagingService.isParticipant.mockResolvedValueOnce(false);
      await expect(controller.sendMessage({ conversationId: 'c1', content: 'h' } as any, { id: 'u1' })).rejects.toThrow(ForbiddenException);
    });

    it('should send message', async () => {
      mockMessagingService.isParticipant.mockResolvedValueOnce(true);
      mockMessagingService.sendMessage.mockResolvedValueOnce({ id: 'm1' });
      const res = await controller.sendMessage({ conversationId: 'c1', content: 'hi' } as any, { id: 'u1' });
      expect(res.id).toBe('m1');
    });
  });
});
