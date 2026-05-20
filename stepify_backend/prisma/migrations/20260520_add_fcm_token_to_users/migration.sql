-- Migration: Add fcmToken column to users table
-- This is a nullable column so no data migration needed

ALTER TABLE "users" ADD COLUMN IF NOT EXISTS "fcmToken" TEXT;
