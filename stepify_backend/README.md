# Stepify Backend API

Production-ready NestJS backend for the Stepify fitness tracking app.

## 🚀 Features

- **Authentication**: JWT + Refresh tokens with OTP verification
- **Step Tracking**: Sync, history, weekly/monthly analytics
- **Rewards System**: Points, streaks, achievements
- **Ad Monetization**: Rewarded ads with cooldowns
- **Redis Caching**: OTP storage, rate limiting, ad cooldowns
- **PostgreSQL**: Prisma ORM with full type safety

## 📦 Prerequisites

- Node.js 18+
- PostgreSQL 14+
- Redis 6+

## 🛠️ Setup

1. **Install dependencies**
   ```bash
   npm install
   ```

2. **Configure environment**
   ```bash
   cp .env.example .env
   # Edit .env with your database & Twilio credentials
   ```

3. **Setup database**
   ```bash
   npx prisma generate
   npx prisma migrate dev
   npm run seed
   ```

4. **Start development server**
   ```bash
   npm run start:dev
   ```

## 🔌 API Endpoints

### Authentication
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/auth/send-otp` | POST | Send OTP to phone/email |
| `/api/v1/auth/verify-otp` | POST | Verify OTP, get tokens |
| `/api/v1/auth/guest` | POST | Create guest account |
| `/api/v1/auth/refresh` | POST | Refresh access token |
| `/api/v1/auth/logout` | POST | Invalidate tokens |

### Steps
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/steps/sync` | POST | Sync step data |
| `/api/v1/steps/today` | GET | Get today's steps |
| `/api/v1/steps/history` | GET | Get step history |
| `/api/v1/steps/weekly` | GET | Weekly summary |
| `/api/v1/steps/monthly` | GET | Monthly summary |

### Rewards
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/rewards/wallet` | GET | Get wallet balance |
| `/api/v1/rewards/transactions` | GET | Transaction history |
| `/api/v1/rewards/streak` | GET | Get streak info |
| `/api/v1/rewards/achievements` | GET | Get achievements |

### Ads
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/ads/can-watch` | GET | Check ad availability |
| `/api/v1/ads/claim` | POST | Claim ad reward |
| `/api/v1/ads/history` | GET | Get ad history |

### User
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/users/me` | GET | Get profile |
| `/api/v1/users/me` | PUT | Update profile |
| `/api/v1/users/me/stats` | GET | Get stats |

## 🐳 Docker (Optional)

```bash
docker-compose up -d
```

## 📝 License

MIT
