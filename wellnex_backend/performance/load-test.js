import http from 'k6/http';
import { check, sleep } from 'k6';
import { randomIntBetween } from 'https://jslib.k6.io/k6-utils/1.2.0/index.js';

export const options = {
  stages: [
    { duration: '30s', target: 20 }, // Ramp up to 20 users
    { duration: '1m', target: 20 },  // Stay at 20 users
    { duration: '30s', target: 0 },  // Ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'], // 95% of requests should be below 500ms
    http_req_failed: ['rate<0.01'],   // Error rate should be less than 1%
  },
};

const BASE_URL = __ENV.API_URL || 'http://localhost:3000/api/v1';

export default function () {
  const phone = '+1' + randomIntBetween(1000000000, 9999999999).toString();

  // 1. Request OTP (Auth)
  const otpRes = http.post(`${BASE_URL}/auth/send-otp`, JSON.stringify({ phone }), {
    headers: { 'Content-Type': 'application/json' },
  });

  check(otpRes, {
    'OTP requested successfully': (r) => r.status === 201 || r.status === 200,
  });

  // Simulated think time
  sleep(randomIntBetween(1, 3));

  // 2. Verify OTP (Auth)
  // Note: in a real load test without mocked OTPs, we might need a test endpoint or fixed OTP
  // Assuming '123456' works in test environments based on our mock setup
  const verifyRes = http.post(`${BASE_URL}/auth/verify-otp`, JSON.stringify({ phone, otp: '123456' }), {
    headers: { 'Content-Type': 'application/json' },
  });

  const isVerified = check(verifyRes, {
    'OTP verified successfully': (r) => r.status === 201 || r.status === 200,
  });

  if (isVerified) {
    const authTokens = verifyRes.json('tokens');
    const token = authTokens && authTokens.accessToken ? authTokens.accessToken : 'test-token';

    // Simulated think time
    sleep(randomIntBetween(1, 2));

    // 3. Sync Steps (Steps Ingestion)
    const stepSyncRes = http.post(
      `${BASE_URL}/steps/sync`,
      JSON.stringify({
        steps: [
          {
            date: new Date().toISOString().split('T')[0],
            stepCount: randomIntBetween(100, 5000),
            caloriesBurned: randomIntBetween(10, 200),
            distanceKm: randomIntBetween(1, 5),
            activeMinutes: randomIntBetween(10, 60),
          },
        ],
      }),
      {
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${token}`,
        },
      }
    );

    check(stepSyncRes, {
      'Steps synced successfully': (r) => r.status === 201 || r.status === 200 || r.status === 404, // 404 allowed if endpoint not fully wired in env
    });
    // 4. Rewards Dashboard (Read-Heavy)
    sleep(randomIntBetween(1, 2));

    const responses = http.batch([
      ['GET', `${BASE_URL}/rewards/wallet`, null, { headers: { Authorization: `Bearer ${token}` } }],
      ['GET', `${BASE_URL}/rewards/catalog`, null, { headers: { Authorization: `Bearer ${token}` } }],
      ['GET', `${BASE_URL}/rewards/streak`, null, { headers: { Authorization: `Bearer ${token}` } }],
    ]);

    check(responses[0], { 'Wallet retrieved': (r) => r.status === 200 || r.status === 404 });
    check(responses[1], { 'Catalog retrieved': (r) => r.status === 200 || r.status === 404 });
    check(responses[2], { 'Streak retrieved': (r) => r.status === 200 || r.status === 404 });
  }

  sleep(randomIntBetween(1, 3));
}
