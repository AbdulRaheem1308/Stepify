import { ActivityType } from "../enums/activity-type.enum";

export const ACTIVITIES_CONSTANTS = {
  MAX_DURATION_MINUTES: 300,
  MAX_POINTS_PER_SESSION: 900,
  DEFAULT_PAGE: 1,
  DEFAULT_LIMIT: 20,
};

export const VALID_ACTIVITY_SOURCES = ['manual', 'gps', 'google_fit', 'apple_health'];


// Speed constraints (km per minute) based on human limits
export const ACTIVITY_SPEED_LIMITS: Record<ActivityType, number> = {
  [ActivityType.RUNNING]: 0.35, // ~21 km/h elite
  [ActivityType.CYCLING]: 0.9, // ~54 km/h sprint
  [ActivityType.WALKING]: 0.12, // ~7.2 km/h fast walk
  [ActivityType.HIKING]: 0.1,
  [ActivityType.SWIMMING]: 0.05, // ~3 km/h
  [ActivityType.YOGA]: 0, // No distance
  [ActivityType.GYM]: 0, // No distance
};

// Point multipliers per minute based on effort
export const ACTIVITY_POINT_MULTIPLIERS: Record<ActivityType, number> = {
  [ActivityType.RUNNING]: 3,
  [ActivityType.SWIMMING]: 3,
  [ActivityType.CYCLING]: 2.5,
  [ActivityType.GYM]: 2.5,
  [ActivityType.WALKING]: 1.5,
  [ActivityType.HIKING]: 2,
  [ActivityType.YOGA]: 1,
};
