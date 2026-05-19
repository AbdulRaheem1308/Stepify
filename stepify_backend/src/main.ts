import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';
import helmet from 'helmet';

async function bootstrap() {
    const app = await NestFactory.create(AppModule);

    // Global prefix for all routes
    app.setGlobalPrefix('api/v1');

    // Security Headers
    app.use(helmet());

    // Configure secure CORS policy
    const allowedOrigins = [
        'http://localhost:3000',
        'http://localhost:5173',
        'https://stepify.app',
        'https://admin.stepify.app'
    ];
    
    app.enableCors({
        origin: (origin, callback) => {
            // Allow requests with no origin (like mobile apps) or specific allowed web origins
            if (!origin || allowedOrigins.includes(origin)) {
                callback(null, true);
            } else {
                callback(new Error('Blocked by CORS'));
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

    const port = process.env.PORT || 3000;
    await app.listen(port);

    console.log(`🚀 Stepify API running on: http://localhost:${port}`);
    console.log(`📚 API Base URL: http://localhost:${port}/api/v1`);
}

bootstrap();
