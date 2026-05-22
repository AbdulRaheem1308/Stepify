import {
  Injectable,
  OnModuleInit,
  OnModuleDestroy,
  Logger,
} from "@nestjs/common";
import { PrismaClient } from "@prisma/client";

@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy
{
  private readonly logger = new Logger(PrismaService.name);

  constructor() {
    super({
      log: [
        { emit: 'event', level: 'query' },
        { emit: 'stdout', level: 'error' },
        { emit: 'stdout', level: 'info' },
        { emit: 'stdout', level: 'warn' },
      ],
    });
  }

  async onModuleInit() {
    // Enable slow query logging
    // @ts-ignore
    this.$on('query', (e: any) => {
      if (e.duration > 200) {
        this.logger.warn(`Slow Query [${e.duration}ms]: ${e.query}`);
      }
    });

    await this.$connect();
    this.logger.log("📦 Database connected with connection pooling enabled");
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}
