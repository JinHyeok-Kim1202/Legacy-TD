import type { DifficultyId, TerminalRarity } from "./common";

export interface RecipeInput {
  unit_id: string;
  count: number;
}

export interface RecipeDefinition {
  id: string;
  inputs: RecipeInput[];
  output_unit_id: string;
  consume_inputs: boolean;
  branch_type: "standard" | TerminalRarity;
  notes?: string;
}

export interface RecipeCatalog {
  recipes: RecipeDefinition[];
}

export interface WaveEntry {
  enemy_id: string;
  count: number;
  spawn_interval: number;
}

export interface WaveDefinition {
  round: number;
  entries: WaveEntry[];
  boss_id: string | null;
}

export interface WaveCatalog {
  waves: WaveDefinition[];
}

export interface DifficultyDefinition {
  id: DifficultyId;
  display_name: string;
  max_active_enemies: number;
  enemy_hp_multiplier: number;
  enemy_damage_multiplier: number;
  enemy_spawn_multiplier: number;
}

export interface DifficultyCatalog {
  difficulties: DifficultyDefinition[];
}

export interface CurrencyDefinition {
  id: string;
  display_name: string;
}

export interface RoundDrawRules {
  base_common_draws_per_round: number;
  bonus_draw_sources: string[];
}

export interface RewardCatalog {
  round_draw_rules: RoundDrawRules;
  currencies: CurrencyDefinition[];
}
