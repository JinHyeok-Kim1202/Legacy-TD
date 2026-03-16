import type { UnitDefinition } from "../../types";

export interface ResolvedOffenseStats {
  physicalDamage: number;
  magicDamage: number;
  attackSpeed: number;
  critChance: number;
}

export function resolveUnitOffense(unit: UnitDefinition): ResolvedOffenseStats {
  return {
    physicalDamage:
      unit.attack.damage_type === "physical"
        ? unit.attack.base_damage + unit.stats.strength * unit.scaling.strength_to_physical_damage
        : 0,
    magicDamage:
      unit.attack.damage_type === "magic"
        ? unit.attack.base_damage + unit.stats.intelligence * unit.scaling.intelligence_to_magic_damage
        : 0,
    attackSpeed: unit.attack.attack_speed + unit.stats.agility * unit.scaling.agility_to_attack_speed,
    critChance: unit.attack.crit_chance + unit.stats.agility * unit.scaling.agility_to_crit_chance,
  };
}
