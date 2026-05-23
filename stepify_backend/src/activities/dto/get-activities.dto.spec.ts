import { plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';
import { GetActivitiesDto } from './get-activities.dto';
import { ACTIVITIES_CONSTANTS } from '../constants/activities.constants';

describe('GetActivitiesDto', () => {
  it('should have default values', () => {
    const dto = new GetActivitiesDto();
    expect(dto.page).toBe(ACTIVITIES_CONSTANTS.DEFAULT_PAGE);
    expect(dto.limit).toBe(ACTIVITIES_CONSTANTS.DEFAULT_LIMIT);
  });

  it('should validate successfully with valid data', async () => {
    const dto = plainToInstance(GetActivitiesDto, { page: 2, limit: 50 });
    const errors = await validate(dto);
    expect(errors.length).toBe(0);
  });

  it('should fail if page is less than 1', async () => {
    const dto = plainToInstance(GetActivitiesDto, { page: 0 });
    const errors = await validate(dto);
    expect(errors.length).toBeGreaterThan(0);
    expect(errors[0].property).toBe('page');
  });

  it('should fail if limit is less than 1', async () => {
    const dto = plainToInstance(GetActivitiesDto, { limit: 0 });
    const errors = await validate(dto);
    expect(errors.length).toBeGreaterThan(0);
    expect(errors[0].property).toBe('limit');
  });

  it('should fail if limit is greater than 100', async () => {
    const dto = plainToInstance(GetActivitiesDto, { limit: 101 });
    const errors = await validate(dto);
    expect(errors.length).toBeGreaterThan(0);
    expect(errors[0].property).toBe('limit');
  });
});
