import { Injectable, Logger } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";

/**
 * PostHog Analytics Service
 * Sends server-side events to PostHog for product analytics and data warehousing.
 *
 * Configuration via environment variables:
 *   POSTHOG_API_KEY=phc_xxxxxxxxxxxx   (required for events to be sent)
 *   POSTHOG_HOST=https://app.posthog.com  (optional, defaults to posthog.com)
 *
 * Events are fire-and-forget — analytics failures never break main app flow.
 */
@Injectable()
export class PostHogService {
  private readonly logger = new Logger(PostHogService.name);
  private readonly apiKey: string;
  private readonly host: string;
  private readonly isEnabled: boolean;

  constructor(private configService: ConfigService) {
    this.apiKey = this.configService.get<string>("POSTHOG_API_KEY", "");
    this.host = this.configService.get<string>(
      "POSTHOG_HOST",
      "https://app.posthog.com",
    );
    this.isEnabled = !!this.apiKey;

    if (!this.isEnabled) {
      this.logger.warn(
        "PostHog API key not set — analytics events will be skipped. Set POSTHOG_API_KEY in .env to enable.",
      );
    } else {
      this.logger.log(`PostHog analytics enabled → ${this.host}`);
    }
  }

  /**
   * Capture a single analytics event for a user.
   * @param distinctId  The user's unique ID (use userId from JWT)
   * @param event       Event name, e.g. 'steps_synced', 'challenge_joined'
   * @param properties  Additional event properties
   */
  async capture(
    distinctId: string,
    event: string,
    properties?: Record<string, any>,
  ): Promise<void> {
    if (!this.isEnabled) return;

    const payload = {
      api_key: this.apiKey,
      distinct_id: distinctId,
      event,
      properties: {
        $lib: "stepify-backend",
        $lib_version: "1.0.0",
        ...properties,
      },
      timestamp: new Date().toISOString(),
    };

    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 3000);

      const res = await fetch(`${this.host}/capture/`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (!res.ok) {
        this.logger.warn(
          `PostHog capture failed: HTTP ${res.status} for event '${event}'`,
        );
      }
    } catch (err: any) {
      // Non-fatal — analytics must never break the main request
      this.logger.warn(
        `PostHog capture error for event '${event}': ${err?.message}`,
      );
    }
  }

  /**
   * Identify / update user properties in PostHog.
   * Call this on login or profile update.
   */
  async identify(
    distinctId: string,
    properties: Record<string, any>,
  ): Promise<void> {
    await this.capture(distinctId, "$identify", {
      $set: properties,
    });
  }

  /**
   * Pre-built event helpers for common Stepify actions
   */
  async trackStepSync(
    userId: string,
    stepCount: number,
    source: string,
  ): Promise<void> {
    await this.capture(userId, "steps_synced", {
      step_count: stepCount,
      source,
    });
  }

  async trackChallengeJoined(
    userId: string,
    challengeId: string,
    challengeTitle: string,
  ): Promise<void> {
    await this.capture(userId, "challenge_joined", {
      challenge_id: challengeId,
      challenge_title: challengeTitle,
    });
  }

  async trackRewardRedeemed(
    userId: string,
    rewardId: string,
    coinCost: number,
  ): Promise<void> {
    await this.capture(userId, "reward_redeemed", {
      reward_id: rewardId,
      coin_cost: coinCost,
    });
  }

  async trackAdWatched(
    userId: string,
    adType: string,
    pointsEarned: number,
  ): Promise<void> {
    await this.capture(userId, "ad_watched", {
      ad_type: adType,
      points_earned: pointsEarned,
    });
  }

  async trackUserLogin(userId: string, method: string): Promise<void> {
    await this.capture(userId, "user_logged_in", { method });
  }

  async trackAchievementUnlocked(
    userId: string,
    achievementCode: string,
    category: string,
  ): Promise<void> {
    await this.capture(userId, "achievement_unlocked", {
      achievement_code: achievementCode,
      category,
    });
  }
}
