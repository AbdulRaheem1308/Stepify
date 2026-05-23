import { Test, TestingModule } from '@nestjs/testing';
import { ActivitiesController } from './activities.controller';
import { ActivitiesService } from './activities.service';
import { LogActivityDto } from './dto/log-activity.dto';
import { ActivityType } from './enums/activity-type.enum';

describe('ActivitiesController', () => {
  let controller: ActivitiesController;
  let service: ActivitiesService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ActivitiesController],
      providers: [
        {
          provide: ActivitiesService,
          useValue: {
            logActivity: jest.fn(),
            getRecentActivities: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<ActivitiesController>(ActivitiesController);
    service = module.get<ActivitiesService>(ActivitiesService);
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('logActivity', () => {
    it('should call logActivity', async () => {
      const user = { id: 'u1' };
      const dto: LogActivityDto = {
        type: ActivityType.RUNNING,
        durationMinutes: 30,
        distanceKm: 5,
        caloriesBurned: 300,
        startTime: new Date().toISOString(),
      };
      
      await controller.logActivity(user, dto);
      expect(service.logActivity).toHaveBeenCalledWith('u1', dto);
    });
  });

  describe('getRecentActivities', () => {
    it('should call getRecentActivities', async () => {
      const user = { id: 'u1' };
      const query = { limit: 10, offset: 0 };
      
      await controller.getRecentActivities(user, query);
      expect(service.getRecentActivities).toHaveBeenCalledWith('u1', query);
    });
  });
});
