import type { GridCoordinate } from "./board-types";
import type { EnemyDefinition } from "./enemy-types";
import type { DifficultyDefinition, WaveDefinition } from "./progression-types";
import type { UnitDefinition } from "./unit-types";

export interface PlacedUnitRuntime {
  instanceId: string;
  definition: UnitDefinition;
  position: GridCoordinate;
  attackCooldownRemaining: number;
}

export interface EnemyRuntime {
  instanceId: string;
  definition: EnemyDefinition;
  currentHp: number;
  pathIndex: number;
  progressToNextTile: number;
  leaked: boolean;
  defeated: boolean;
}

export interface CombatRuntimeState {
  round: number;
  wave: WaveDefinition;
  difficulty: DifficultyDefinition;
  path: GridCoordinate[];
  units: PlacedUnitRuntime[];
  enemies: EnemyRuntime[];
  leakedEnemyCount: number;
  totalGoldEarned: number;
}

export interface AttackResolution {
  attackerId: string;
  targetId: string;
  damageApplied: number;
  wasCritical: boolean;
  targetDefeated: boolean;
}

export interface CombatTickResult {
  state: CombatRuntimeState;
  attacks: AttackResolution[];
  leakedThisTick: number;
  defeatedEnemyIds: string[];
  roundCleared: boolean;
  gameOver: boolean;
}
