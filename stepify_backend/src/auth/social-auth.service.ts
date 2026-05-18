import { Injectable, OnModuleInit, UnauthorizedException, Logger } from '@nestjs/common';
import * as admin from 'firebase-admin';

@Injectable()
export class SocialAuthService implements OnModuleInit {
    private readonly logger = new Logger(SocialAuthService.name);

    onModuleInit() {
        if (!admin.apps.length) {
            try {
                // In production, we expect FIREBASE_SERVICE_ACCOUNT_JSON or proper Google Cloud Identity
                // For now, we try default application credentials
                if (process.env.FIREBASE_PROJECT_ID && process.env.FIREBASE_CLIENT_EMAIL && process.env.FIREBASE_PRIVATE_KEY) {
                    admin.initializeApp({
                        credential: admin.credential.cert({
                            projectId: process.env.FIREBASE_PROJECT_ID,
                            clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
                            privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
                        }),
                    });
                    this.logger.log('Firebase Admin Initialized with Env Vars');
                } else {
                    admin.initializeApp({
                        credential: admin.credential.applicationDefault()
                    });
                    this.logger.log('Firebase Admin Initialized with Default Credentials');
                }
            } catch (error) {
                this.logger.warn('Failed to initialize Firebase Admin. Social Login will fail.', error);
            }
        }
    }

    async verifyIdToken(idToken: string): Promise<admin.auth.DecodedIdToken> {
        try {
            // This verifies the signature, expiration, and audience (project match)
            const decodedToken = await admin.auth().verifyIdToken(idToken);
            return decodedToken;
        } catch (error) {
            this.logger.error(`Token Verification Failed: ${error.message}`);
            throw new UnauthorizedException('Invalid or Expired ID Token');
        }
    }
}
