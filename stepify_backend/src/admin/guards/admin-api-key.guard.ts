import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
  Logger,
} from "@nestjs/common";
import { Request } from "express";

@Injectable()
export class AdminApiKeyGuard implements CanActivate {
  private readonly logger = new Logger(AdminApiKeyGuard.name);

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<Request>();

    // Check header
    const apiKey = request.headers["x-admin-api-key"] as string;

    // Optional: Allow bypassing via query param for HTML view rendering ONLY if needed.
    // We only enforce this on /api/* routes, so header is fine.

    if (!apiKey) {
      this.logger.warn(
        `Blocked unauthorized admin access from IP: ${request.ip}`,
      );
      throw new UnauthorizedException("Missing Admin API Key");
    }

    const validKey =
      process.env.ADMIN_API_KEY || "fallback-secret-admin-key-2026"; // Fallback to avoid complete lockdown if not set in dev

    if (apiKey !== validKey) {
      this.logger.warn(
        `Invalid admin API key attempted from IP: ${request.ip}`,
      );
      throw new UnauthorizedException("Invalid Admin API Key");
    }

    return true;
  }
}
