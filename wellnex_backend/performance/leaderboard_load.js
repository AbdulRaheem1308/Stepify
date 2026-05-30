import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

// ─── Custom Metrics ──────────────────────────────────────────────────────────
const errorRate = new Rate('error_rate');
const leaderboardDuration = new Trend('leaderboard_duration', true);
const feedDuration = new Trend('community_feed_duration', true);

// ─── Test Configuration ───────────────────────────────────────────────────────
export const options = {
  stages: [
    { duration: '30s', target: 20 },   // Ramp-up:   0 → 20 VUs over 30s
    { duration: '1m',  target: 100 },  // Load:      20 → 100 VUs over 1m
    { duration: '30s', target: 100 },  // Steady:    hold 100 VUs for 30s
    { duration: '30s', target: 0 },    // Ramp-down: 100 → 0 VUs over 30s
  ],
  thresholds: {
    // 95th percentile of all requests must finish in under 500ms
    http_req_duration: ['p(95)<500'],
    // Error rate must stay below 1%
    error_rate: ['rate<0.01'],
    // Leaderboard endpoint p(95) under 300ms (cached by Redis)
    leaderboard_duration: ['p(95)<300'],
  },
};

// ─── Environment Config ────────────────────────────────────────────────────────
const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000/api/v1';

// A valid JWT token for a test user (set via env: k6 run -e JWT_TOKEN=xxx ...)
const JWT_TOKEN = __ENV.JWT_TOKEN || 'replace_with_valid_token';

const HEADERS = {
  Authorization: `Bearer ${JWT_TOKEN}`,
  'Content-Type': 'application/json',
};

// ─── Test Scenarios ────────────────────────────────────────────────────────────
export default function () {
  // 1. Referral Leaderboard (Redis-cached → should be very fast)
  const leaderboardStart = Date.now();
  const leaderboardRes = http.get(`${BASE_URL}/users/referral/leaderboard`, {
    headers: HEADERS,
  });
  leaderboardDuration.add(Date.now() - leaderboardStart);

  check(leaderboardRes, {
    'leaderboard status is 200': (r) => r.status === 200,
    'leaderboard returns array': (r) => {
      try {
        const body = JSON.parse(r.body as string);
        return Array.isArray(body);
      } catch {
        return false;
      }
    },
  }) || errorRate.add(1);

  sleep(0.5);

  // 2. Community Feed (Redis-cached first page → should be fast)
  const feedStart = Date.now();
  const feedRes = http.get(`${BASE_URL}/community/feed?limit=20`, {
    headers: HEADERS,
  });
  feedDuration.add(Date.now() - feedStart);

  check(feedRes, {
    'feed status is 200': (r) => r.status === 200,
    'feed returns array': (r) => {
      try {
        const body = JSON.parse(r.body as string);
        return Array.isArray(body);
      } catch {
        return false;
      }
    },
  }) || errorRate.add(1);

  sleep(0.5);

  // 3. My Profile (DB read – tests general latency)
  const profileRes = http.get(`${BASE_URL}/users/me`, { headers: HEADERS });
  check(profileRes, {
    'profile status is 200 or 401': (r) => [200, 401].includes(r.status),
  }) || errorRate.add(1);

  sleep(1);
}
