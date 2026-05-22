import { NestFactory } from '@nestjs/core';
import { Logger } from '@nestjs/common';
import * as Sentry from '@sentry/nestjs';
import { otelSDK } from './tracing';

jest.mock('@nestjs/core', () => {
  const mockApp = {
    get: jest.fn().mockReturnValue({}),
    useGlobalFilters: jest.fn(),
    setGlobalPrefix: jest.fn(),
    use: jest.fn(),
    enableCors: jest.fn(),
    useGlobalPipes: jest.fn(),
    listen: jest.fn().mockResolvedValue(true),
  };
  return {
    NestFactory: {
      create: jest.fn().mockResolvedValue(mockApp),
    },
    HttpAdapterHost: jest.fn().mockImplementation(() => ({})),
  };
});

jest.mock('./app.module', () => ({
  AppModule: class {},
}));

jest.mock('./tracing', () => ({
  otelSDK: { start: jest.fn() },
}));

jest.mock('@sentry/nestjs', () => ({
  init: jest.fn(),
}));

jest.mock('./common/filters/sentry-exception.filter', () => ({
  SentryExceptionFilter: class {},
}));

jest.mock('nestjs-i18n', () => ({
  I18nService: class {},
}));

jest.mock('@nestjs/swagger', () => {
  return {
    SwaggerModule: {
      createDocument: jest.fn(),
      setup: jest.fn(),
    },
    DocumentBuilder: class {
      setTitle() { return this; }
      setDescription() { return this; }
      setVersion() { return this; }
      addBearerAuth() { return this; }
      build() { return {}; }
    },
  };
});

describe('Main Bootstrap', () => {
  let loggerSpy: jest.SpyInstance;

  beforeAll(() => {
    loggerSpy = jest.spyOn(Logger, 'log').mockImplementation(() => {});
  });

  afterAll(() => {
    loggerSpy.mockRestore();
  });

  it('should bootstrap the application', async () => {
    jest.isolateModules(() => {
      require('./main');
    });

    await new Promise(resolve => setTimeout(resolve, 100));

    expect(otelSDK.start).toHaveBeenCalled();
    expect(Sentry.init).toHaveBeenCalled();
    expect(NestFactory.create).toHaveBeenCalled();
  });
});
