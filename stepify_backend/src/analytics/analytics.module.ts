import { Module, Global } from '@nestjs/common';
import { PostHogService } from './posthog.service';

/**
 * Global analytics module — PostHogService is available for injection
 * in any other module without needing to import AnalyticsModule explicitly.
 */
@Global()
@Module({
    providers: [PostHogService],
    exports: [PostHogService],
})
export class AnalyticsModule {}
