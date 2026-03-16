import type { DamageType, PlacementRules, PresentationRef, Rarity, TargetingMode } from "./common";

export interface UnitAttackProfile {
  damage_type: DamageType;
  targeting: TargetingMode;
  range: number;
  attack_speed: number;
  base_damage: number;
  crit_chance: number;
  crit_multiplier: number;
}

export interface UnitStats {
  strength: number;
  agility: number;
  intelligence: number;
  max_hp: number;
}

export interface UnitScaling {
  strength_to_physical_damage: number;
  agility_to_attack_speed: number;
  agility_to_crit_chance: number;
  intelligence_to_magic_damage: number;
}

export interface UnitDefinition {
  id: string;
  codename: string;
  display_name: string;
  rarity: Rarity;
  branch_family?: string;
  placement: PlacementRules;
  attack: UnitAttackProfile;
  stats: UnitStats;
  scaling: UnitScaling;
  presentation: PresentationRef & { icon_id: string };
  tags: string[];
}

export interface UnitCatalog {
  units: UnitDefinition[];
}

export interface UnitRarityDefinition {
  id: Rarity;
  order: number;
  is_terminal_branch: boolean;
}

export interface UnitRarityCatalog {
  rarities: UnitRarityDefinition[];
}
