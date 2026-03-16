export type Rarity =
  | "common"
  | "rare"
  | "unique"
  | "legendary"
  | "transcendent"
  | "immortal"
  | "god"
  | "liberator";

export type TerminalRarity = "transcendent" | "immortal" | "god" | "liberator";

export type DamageType = "physical" | "magic";

export type TargetingMode = "first" | "last" | "strongest" | "weakest" | "nearest";

export type DifficultyId = "easy" | "normal" | "hard";

export interface PlacementRules {
  board_allowed: boolean;
  storage_allowed: boolean;
}

export interface PresentationRef {
  model_id: string;
  icon_id?: string;
}
