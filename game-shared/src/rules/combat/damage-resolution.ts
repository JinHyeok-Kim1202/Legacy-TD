import type { EnemyRuntime, PlacedUnitRuntime } from "../../types";
import { resolveUnitOffense } from "./stat-scaling";

export interface DamageRollInput {
  criticalRoll?: number;
}

export interface DamageResult {
  damageApplied: number;
  wasCritical: boolean;
  targetDefeated: boolean;
}

function clampMinimumDamage(value: number): number {
  return value < 1 ? 1 : value;
}

export function resolveAttackDamage(
  attacker: PlacedUnitRuntime,
  target: EnemyRuntime,
  input: DamageRollInput = {}
): DamageResult {
  const offense = resolveUnitOffense(attacker.definition);
  const critRoll = input.criticalRoll ?? 1;
  const wasCritical = critRoll <= offense.critChance;

  const rawDamage =
    attacker.definition.attack.damage_type === "physical"
      ? offense.physicalDamage - target.definition.combat.armor
      : offense.magicDamage * (1 - target.definition.combat.magic_resist);

  const criticalMultiplier = wasCritical ? attacker.definition.attack.crit_multiplier : 1;
  const damageApplied = clampMinimumDamage(Math.round(rawDamage * criticalMultiplier));
  target.currentHp = Math.max(0, target.currentHp - damageApplied);
  target.defeated = target.currentHp <= 0;

  return {
    damageApplied,
    wasCritical,
    targetDefeated: target.defeated,
  };
}
