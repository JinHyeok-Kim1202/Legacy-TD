import type { PresentationRef } from "./common";

export interface EnemyMovement {
  path_id: string;
  move_speed: number;
}

export interface EnemyCombat {
  max_hp: number;
  armor: number;
  magic_resist: number;
}

export interface EnemyReward {
  gold: number;
}

export interface EnemyDefinition {
  id: string;
  display_name: string;
  type: string;
  movement: EnemyMovement;
  combat: EnemyCombat;
  reward: EnemyReward;
  presentation: PresentationRef;
  tags: string[];
}

export interface EnemyCatalog {
  enemies: EnemyDefinition[];
}

export interface BossAbility {
  id: string;
  cooldown: number;
  description: string;
}

export interface BossReward {
  gold: number;
  bonus_common_draws: number;
}

export interface BossDefinition {
  id: string;
  display_name: string;
  spawn_round: number;
  movement: EnemyMovement;
  combat: EnemyCombat;
  abilities: BossAbility[];
  reward: BossReward;
  presentation: PresentationRef;
}

export interface BossCatalog {
  bosses: BossDefinition[];
}
