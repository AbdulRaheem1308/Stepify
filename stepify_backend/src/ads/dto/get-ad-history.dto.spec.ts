import { plainToInstance } from 'class-transformer';
import { validate } from 'class-validator';
import { GetAdHistoryDto } from './get-ad-history.dto';

describe('GetAdHistoryDto', () => {
  it('should have default values', () => {
    const dto = new GetAdHistoryDto();
    expect(dto.page).toBe(1);
    expect(dto.limit).toBe(20);
  });

  it('should validate successfully with valid data', async () => {
    const dto = plainToInstance(GetAdHistoryDto, { page: 2, limit: 50 });
    const errors = await validate(dto);
    expect(errors.length).toBe(0);
  });

  it('should fail if page is less than 1', async () => {
    const dto = plainToInstance(GetAdHistoryDto, { page: 0 });
    const errors = await validate(dto);
    expect(errors.length).toBeGreaterThan(0);
    expect(errors[0].property).toBe('page');
  });

  it('should fail if limit is less than 1', async () => {
    const dto = plainToInstance(GetAdHistoryDto, { limit: 0 });
    const errors = await validate(dto);
    expect(errors.length).toBeGreaterThan(0);
    expect(errors[0].property).toBe('limit');
  });

  it('should fail if limit is greater than 100', async () => {
    const dto = plainToInstance(GetAdHistoryDto, { limit: 101 });
    const errors = await validate(dto);
    expect(errors.length).toBeGreaterThan(0);
    expect(errors[0].property).toBe('limit');
  });
});
