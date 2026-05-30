import { Injectable, Logger } from "@nestjs/common";
import { Cron } from "@nestjs/schedule";

@Injectable()
export class KeepAwakeService {
  private readonly logger = new Logger(KeepAwakeService.name);

  // Run every 14 minutes
  @Cron("0 */14 * * * *")
  async handleCron() {
    // Render automatically injects RENDER_EXTERNAL_URL into your environment
    const externalUrl = process.env.RENDER_EXTERNAL_URL;

    if (!externalUrl) {
      this.logger.debug(
        "RENDER_EXTERNAL_URL is not set. Skipping keep-awake ping.",
      );
      return;
    }

    const healthUrl = `${externalUrl}/api/v1/health`;

    try {
      this.logger.log(
        `Pinging ${healthUrl} to keep backend awake on Render free tier...`,
      );

      // We use the global fetch API (available in Node 18+)
      const response = await fetch(healthUrl);

      if (response.ok) {
        this.logger.log(
          `Keep-awake ping successful: ${response.status} ${response.statusText}`,
        );
      } else {
        this.logger.error(
          `Keep-awake ping failed with status: ${response.status}`,
        );
      }
    } catch (error) {
      this.logger.error(
        `Keep-awake ping error: ${error instanceof Error ? error.message : String(error)}`,
      );
    }
  }
}
