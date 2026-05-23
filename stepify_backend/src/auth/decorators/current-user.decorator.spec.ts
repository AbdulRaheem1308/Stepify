import { CurrentUser } from './current-user.decorator';
import { ExecutionContext } from '@nestjs/common';
import { ROUTE_ARGS_METADATA } from '@nestjs/common/constants';

function getParamDecoratorFactory(decorator: any) {
  class Test {
    public test(@decorator() _value: any) {}
  }

  const args = Reflect.getMetadata(ROUTE_ARGS_METADATA, Test, 'test');
  return args[Object.keys(args)[0]].factory;
}

describe('CurrentUser Decorator', () => {
  it('should extract user from request', () => {
    const factory = getParamDecoratorFactory(CurrentUser);
    
    const mockUser = { id: 'user1', email: 'test@test.com' };
    const mockContext = {
      switchToHttp: () => ({
        getRequest: () => ({
          user: mockUser,
        }),
      }),
    } as ExecutionContext;

    const result = factory(null, mockContext);
    expect(result).toEqual(mockUser);
  });

  it('should return undefined if user is not on request', () => {
    const factory = getParamDecoratorFactory(CurrentUser);
    
    const mockContext = {
      switchToHttp: () => ({
        getRequest: () => ({}),
      }),
    } as ExecutionContext;

    const result = factory(null, mockContext);
    expect(result).toBeUndefined();
  });
});
