export const BOARD_ROWS = 5;
export const BOARD_COLS = 5;
export const OUTER_RING_PATH_ID = "outer_ring_clockwise";
export const SURVIVAL_TARGET_ROUND = 100;
export const BOSS_INTERVAL_ROUNDS = 10;
export const BASE_COMMON_DRAWS_PER_ROUND = 2;

export const RARITY_ORDER = [
  "common",
  "rare",
  "unique",
  "legendary",
  "transcendent",
  "immortal",
  "god",
  "liberator",
] as const;

export const TERMINAL_RARITIES = [
  "transcendent",
  "immortal",
  "god",
  "liberator",
] as const;

export const DAMAGE_TYPES = ["physical", "magic"] as const;
export const TARGETING_MODES = [
  "first",
  "last",
  "strongest",
  "weakest",
  "nearest",
] as const;

export const DIFFICULTY_IDS = ["easy", "normal", "hard"] as const;
