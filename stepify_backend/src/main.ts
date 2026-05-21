import { NestFactory, HttpAdapterHost } from "@nestjs/core";
import { ValidationPipe } from "@nestjs/common";
import { AppModule } from "./app.module";
import helmet from "helmet";
import { SwaggerModule, DocumentBuilder } from "@nestjs/swagger";
import * as Sentry from "@sentry/nestjs";
import {
  WinstonModule,
  utilities as nestWinstonModuleUtilities,
} from "nest-winston";
import * as winston from "winston";
import { SentryExceptionFilter } from "./common/filters/sentry-exception.filter";

// Initialize Sentry before anything else
Sentry.init({
  dsn: process.env.SENTRY_DSN || "https://mockDsnKey@o0.ingest.sentry.io/0",
  environment: process.env.NODE_ENV || "development",
  tracesSampleRate: 1.0,
});

async function bootstrap() {
  // Configure Winston structured and colorized logging
  const winstonLogger = WinstonModule.createLogger({
    transports: [
      new winston.transports.Console({
        format: winston.format.combine(
          winston.format.timestamp(),
          winston.format.ms(),
          process.env.NODE_ENV === "production"
            ? winston.format.json()
            : nestWinstonModuleUtilities.format.nestLike("Stepify", {
                colors: true,
                prettyPrint: true,
              }),
        ),
      }),
    ],
  });

  const app = await NestFactory.create(AppModule, {
    logger: winstonLogger,
  });

  // Global Sentry Exception Filter
  const { httpAdapter } = app.get(HttpAdapterHost);
  app.useGlobalFilters(new SentryExceptionFilter(httpAdapter));

  // Global prefix for all routes
  app.setGlobalPrefix("api/v1");

  // Security Headers
  app.use(helmet());

  // Configure secure CORS policy
  const allowedOrigins = [
    "http://localhost:3000",
    "http://localhost:5173",
    "https://stepify.app",
    "https://admin.stepify.app",
  ];

  app.enableCors({
    origin: (origin, callback) => {
      // Allow requests with no origin (like mobile apps) or specific allowed web origins
      if (!origin || allowedOrigins.includes(origin)) {
        callback(null, true);
      } else {
        callback(new Error("Blocked by CORS"));
      }
    },
    credentials: true,
  });

  // Global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  // Setup interactive Swagger documentation
  const config = new DocumentBuilder()
    .setTitle("Stepify API")
    .setDescription(
      "Stepify - Fitness Step Tracking API Documentation (Hardened & Secure)",
    )
    .setVersion("1.0.0")
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup("api/docs", app, document);

  const port = process.env.PORT || 3000;
  await app.listen(port, "0.0.0.0");

  console.log(`🚀 Stepify API running on: http://localhost:${port}`);
  console.log(`📚 API Base URL: http://localhost:${port}/api/v1`);
  console.log(`📖 Swagger API Docs: http://localhost:${port}/api/docs`);
}

bootstrap();
