import { Test, TestingModule } from '@nestjs/testing';
import { CommunityController } from './community.controller';
import { CommunityService } from './community.service';

describe('CommunityController', () => {
  let controller: CommunityController;
  let service: CommunityService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [CommunityController],
      providers: [
        {
          provide: CommunityService,
          useValue: {
            getFeed: jest.fn(),
            createPost: jest.fn(),
            reactToPost: jest.fn(),
            getComments: jest.fn(),
            addComment: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<CommunityController>(CommunityController);
    service = module.get<CommunityService>(CommunityService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('getFeed', () => {
    it('should call getFeed with default limit if not provided', async () => {
      await controller.getFeed();
      expect(service.getFeed).toHaveBeenCalledWith(20, undefined);
    });

    it('should call getFeed with provided limit and cursor', async () => {
      await controller.getFeed(10, 'cursor123');
      expect(service.getFeed).toHaveBeenCalledWith(10, 'cursor123');
    });
  });

  describe('createPost', () => {
    it('should call createPost with default type', async () => {
      const user = { id: 'u1' };
      await controller.createPost(user, { content: 'test content' });
      expect(service.createPost).toHaveBeenCalledWith('u1', 'test content', 'MANUAL');
    });

    it('should call createPost with provided type', async () => {
      const user = { id: 'u1' };
      await controller.createPost(user, { content: 'test content', type: 'ACHIEVEMENT' });
      expect(service.createPost).toHaveBeenCalledWith('u1', 'test content', 'ACHIEVEMENT');
    });
  });

  describe('reactToPost', () => {
    it('should call reactToPost with default type', async () => {
      const user = { id: 'u1' };
      await controller.reactToPost(user, 'p1', {});
      expect(service.reactToPost).toHaveBeenCalledWith('u1', 'p1', 'like');
    });

    it('should call reactToPost with provided type', async () => {
      const user = { id: 'u1' };
      await controller.reactToPost(user, 'p1', { type: 'clap' });
      expect(service.reactToPost).toHaveBeenCalledWith('u1', 'p1', 'clap');
    });
  });

  describe('getComments', () => {
    it('should call getComments', async () => {
      await controller.getComments('p1');
      expect(service.getComments).toHaveBeenCalledWith('p1');
    });
  });

  describe('addComment', () => {
    it('should call addComment', async () => {
      const user = { id: 'u1' };
      await controller.addComment(user, 'p1', { content: 'test comment' });
      expect(service.addComment).toHaveBeenCalledWith('u1', 'p1', 'test comment');
    });
  });
});
