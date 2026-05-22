import { Injectable, Logger } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import Twilio from "twilio";
import * as crypto from "node:crypto";

@Injectable()
export class OtpService {
  private readonly logger = new Logger(OtpService.name);
  private readonly twilioClient: Twilio.Twilio | null = null;

  constructor(private readonly configService: ConfigService) {
    const accountSid = this.configService.get("TWILIO_ACCOUNT_SID");
    const authToken = this.configService.get("TWILIO_AUTH_TOKEN");
    const isProduction = this.configService.get("NODE_ENV") === "production";

    if (accountSid && authToken && !accountSid.startsWith("AC_YOUR")) {
      this.twilioClient = Twilio(accountSid, authToken);
      this.logger.log("Twilio client initialized");
    } else {
      if (isProduction) {
        this.logger.error(
          "CRITICAL: Twilio credentials missing or invalid in PRODUCTION mode! SMS OTPs will fail.",
        );
      }
      this.logger.warn(
        "Twilio not configured - OTPs will be logged to console",
      );
    }
  }

  generateOtp(): string {
    const length = this.configService.get<number>("OTP_LENGTH", 6);
    let otp = "";
    for (let i = 0; i < length; i++) {
      otp += crypto.randomInt(0, 10).toString();
    }
    return otp;
  }

  async sendSmsOtp(phone: string, otp: string): Promise<void> {
    const message = `Your Stepify verification code is: ${otp}. Valid for 5 minutes.`;

    if (this.twilioClient) {
      try {
        await this.twilioClient.messages.create({
          body: message,
          from: this.configService.get("TWILIO_PHONE_NUMBER"),
          to: phone,
        });
        this.logger.log(`OTP sent to ${phone}`);
      } catch (error) {
        this.logger.error(`Failed to send SMS to ${phone}:`, error.message);
        this.logOtpForDevelopment(phone, otp);
      }
    } else {
      this.logOtpForDevelopment(phone, otp);
    }
  }

  async sendEmailOtp(email: string, otp: string): Promise<void> {
    this.logger.log(`Email OTP for ${email}: ${otp}`);
    this.logger.log("\n========================================");
    this.logger.log(`EMAIL OTP for ${email}`);
    this.logger.log(`Code: ${otp}`);
    this.logger.log("========================================\n");
  }

  private logOtpForDevelopment(identifier: string, otp: string): void {
    this.logger.log("\n========================================");
    this.logger.log(`DEV MODE - OTP for ${identifier}`);
    this.logger.log(`Code: ${otp}`);
    this.logger.log("========================================\n");
  }
}
