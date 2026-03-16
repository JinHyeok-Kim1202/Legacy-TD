import type {
  AttackResolution,
  CombatRuntimeState,
  CombatTickResult,
  EnemyDefinition,
  EnemyRuntime,
  GridCoordinate,
  PlacedUnitRuntime,
  WaveDefinition,
} from "../../types";
import { isGameOverFromLeaks } from "../loss-condition/leak-threshold";
import { resolveAttackDamage } from "./damage-resolution";
import { advanceEnemies } from "./enemy-movement";
import { selectTarget } from "./target-selection";
import { resolveUnitOffense } from "./stat-scaling";

export interface SpawnEnemyInstanceParams {
  instanceId: string;
  definition: EnemyDefinition;
}

export function createEnemyRuntime(params: SpawnEnemyInstanceParams): EnemyRuntime {
  return {
    instanceId: params.instanceId,
    definition: params.definition,
    currentHp: params.definition.combat.max_hp,
    pathIndex: 0,
    progressToNextTile: 0,
    leaked: false,
    defeated: false,
  };
}

export interface CreateCombatStateParams {
  round: number;
  wave: WaveDefinition;
  difficulty: CombatRuntimeState["difficulty"];
  path: GridCoordinate[];
  units: PlacedUnitRuntime[];
  enemies: EnemyRuntime[];
}

export function createCombatRuntimeState(params: CreateCombatStateParams): CombatRuntimeState {
  return {
    round: params.round,
    wave: params.wave,
    difficulty: params.difficulty,
    path: params.path,
    units: params.units,
    enemies: params.enemies,
    leakedEnemyCount: 0,
    totalGoldEarned: 0,
  };
}

function resolveUnitAttacks(state: CombatRuntimeState, deltaSeconds: number): AttackResolution[] {
  const attacks: AttackResolution[] = [];

  for (const unit of state.units) {
    unit.attackCooldownRemaining = Math.max(0, unit.attackCooldownRemaining - deltaSeconds);
    if (unit.attackCooldownRemaining > 0) {
      continue;
    }

    const target = selectTarget(unit, state.enemies, state.path);
    if (!target) {
      continue;
    }

    const result = resolveAttackDamage(unit, target);
    const offense = resolveUnitOffense(unit.definition);
    unit.attackCooldownRemaining = 1 / Math.max(0.001, offense.attackSpeed);

    if (result.targetDefeated) {
      state.totalGoldEarned += target.definition.reward.gold;
    }

    attacks.push({
      attackerId: unit.instanceId,
      targetId: target.instanceId,
      damageApplied: result.damageApplied,
      wasCritical: result.wasCritical,
      targetDefeated: result.targetDefeated,
    });
  }

  return attacks;
}

function isRoundCleared(state: CombatRuntimeState): boolean {
  return state.enemies.every((enemy) => enemy.defeated || enemy.leaked);
}

export function stepCombatTick(state: CombatRuntimeState, deltaSeconds: number): CombatTickResult {
  const leakedThisTick = advanceEnemies(state, deltaSeconds);
  const attacks = resolveUnitAttacks(state, deltaSeconds);
  const defeatedEnemyIds = state.enemies.filter((enemy) => enemy.defeated).map((enemy) => enemy.instanceId);
  const roundCleared = isRoundCleared(state);
  const gameOver = isGameOverFromLeaks(state.leakedEnemyCount, state.difficulty);

  return {
    state,
    attacks,
    leakedThisTick,
    defeatedEnemyIds,
    roundCleared,
    gameOver,
  };
}
