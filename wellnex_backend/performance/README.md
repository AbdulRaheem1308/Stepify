# Wellnex Backend Load Testing

This directory contains the `k6` load testing script to test the backend stability under simulated user load.

## Setup
Ensure you have [k6 installed](https://k6.io/docs/get-started/installation/).

## Running Tests
Run the test against your local development environment:
```bash
npm run test:load
```
Or directly via k6:
```bash
k6 run performance/load-test.js
```

## Environment Variables
- `API_URL`: The base URL of the backend (default: `http://localhost:3000/api/v1`)

## Test Scenario
The script simulates a typical user session:
1. **Auth:** User requests an OTP and verifies it to get a JWT token.
2. **Steps Sync:** User's device syncs their daily steps.
3. **Rewards Dashboard:** User opens the rewards tab, triggering concurrent requests for wallet, catalog, and streak.

## Goal Thresholds
- 95% of all HTTP requests must complete in under **500ms**.
- The overall error rate must be **< 1%**.
