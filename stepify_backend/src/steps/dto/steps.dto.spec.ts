import { plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';
import { SyncStepsDto, DeviceIntegrityDto } from './steps.dto';

describe('SyncStepsDto', () => {
  it('should validate successfully with valid data', async () => {
    const data = {
      deviceIdentifier: 'id123',
      date: '2026-05-20',
      stepCount: 5000,
      integrity: {
        isJailBroken: false,
        isRealDevice: true,
        isMockLocation: false,
      },
    };
    const dto = plainToInstance(SyncStepsDto, data);
    const errors = await validate(dto);
    expect(errors.length).toBe(0);
  });

  it('should fail if deviceIdentifier is missing', async () => {
    const data = {
      date: '2026-05-20',
      stepCount: 5000,
    };
    const dto = plainToInstance(SyncStepsDto, data);
    const errors = await validate(dto);
    expect(errors.length).toBeGreaterThan(0);
    expect(errors[0].property).toBe('deviceIdentifier');
  });

  it('should fail if stepCount is negative', async () => {
    const data = {
      deviceIdentifier: 'id123',
      date: '2026-05-20',
      stepCount: -1,
    };
    const dto = plainToInstance(SyncStepsDto, data);
    const errors = await validate(dto);
    expect(errors.length).toBeGreaterThan(0);
    expect(errors[0].property).toBe('stepCount');
  });

  describe('DeviceIntegrityDto', () => {
    it('should fail if integrity fields are not boolean', async () => {
      const data = {
        deviceIdentifier: 'id123',
        date: '2026-05-20',
        stepCount: 5000,
        integrity: {
          isJailBroken: 'no',
          isRealDevice: true,
          isMockLocation: false,
        },
      };
      const dto = plainToInstance(SyncStepsDto, data);
      const errors = await validate(dto);
      expect(errors.length).toBeGreaterThan(0);
      expect(errors[0].property).toBe('integrity');
    });
  });
});
