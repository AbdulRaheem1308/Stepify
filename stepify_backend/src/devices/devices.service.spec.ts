import { Test, TestingModule } from '@nestjs/testing';
import { DevicesService } from './devices.service';
import { PrismaService } from '../prisma/prisma.service';

describe('DevicesService', () => {
  let service: DevicesService;
  let prisma: PrismaService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        DevicesService,
        {
          provide: PrismaService,
          useValue: {
            device: {
              findMany: jest.fn(),
              create: jest.fn(),
              findFirst: jest.fn(),
              update: jest.fn(),
              updateMany: jest.fn(),
            },
          },
        },
      ],
    }).compile();

    service = module.get<DevicesService>(DevicesService);
    prisma = module.get<PrismaService>(PrismaService);
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('getUserDevices', () => {
    it('should return user devices', async () => {
      const mockDevices = [{ id: '1' }];
      (prisma.device.findMany as jest.Mock).mockResolvedValue(mockDevices);

      const result = await service.getUserDevices('user1');

      expect(prisma.device.findMany).toHaveBeenCalledWith({
        where: { userId: 'user1', isActive: true },
        orderBy: { createdAt: 'desc' },
      });
      expect(result).toEqual(mockDevices);
    });
  });

  describe('addDevice', () => {
    it('should add a new device', async () => {
      const dto = { name: 'Watch', type: 'APPLE_WATCH', identifier: 'abc' };
      const mockDevice = { id: '1', ...dto };
      (prisma.device.create as jest.Mock).mockResolvedValue(mockDevice);

      const result = await service.addDevice('user1', dto as any);

      expect(prisma.device.create).toHaveBeenCalledWith({
        data: {
          userId: 'user1',
          name: dto.name,
          type: dto.type,
          identifier: dto.identifier,
        },
      });
      expect(result).toEqual(mockDevice);
    });
  });

  describe('syncDevice', () => {
    it('should throw an error if device not found', async () => {
      (prisma.device.findFirst as jest.Mock).mockResolvedValue(null);

      await expect(service.syncDevice('user1', 'device1')).rejects.toThrow('Device not found');
    });

    it('should sync device if found', async () => {
      (prisma.device.findFirst as jest.Mock).mockResolvedValue({ id: 'device1' });
      const mockUpdated = { id: 'device1', lastSyncedAt: new Date() };
      (prisma.device.update as jest.Mock).mockResolvedValue(mockUpdated);

      const result = await service.syncDevice('user1', 'device1');

      expect(prisma.device.update).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { id: 'device1' },
          data: expect.objectContaining({
            lastSyncedAt: expect.any(Date),
          }),
        })
      );
      expect(result).toEqual(mockUpdated);
    });
  });

  describe('removeDevice', () => {
    it('should remove a device', async () => {
      (prisma.device.updateMany as jest.Mock).mockResolvedValue({ count: 1 });

      const result = await service.removeDevice('user1', 'device1');

      expect(prisma.device.updateMany).toHaveBeenCalledWith({
        where: { id: 'device1', userId: 'user1' },
        data: { isActive: false },
      });
      expect(result).toEqual({ count: 1 });
    });
  });

  describe('findByIdentifier', () => {
    it('should find device by identifier', async () => {
      const mockDevice = { id: '1' };
      (prisma.device.findFirst as jest.Mock).mockResolvedValue(mockDevice);

      const result = await service.findByIdentifier('user1', 'abc');

      expect(prisma.device.findFirst).toHaveBeenCalledWith({
        where: { userId: 'user1', identifier: 'abc', isActive: true },
      });
      expect(result).toEqual(mockDevice);
    });
  });
});
