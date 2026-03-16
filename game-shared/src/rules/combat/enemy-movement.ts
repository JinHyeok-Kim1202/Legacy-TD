import type { CombatRuntimeState, EnemyRuntime } from "../../types";

function advanceEnemy(enemy: EnemyRuntime, deltaSeconds: number, pathLength: number): number {
  if (enemy.defeated || enemy.leaked) {
    return 0;
  }

  enemy.progressToNextTile += enemy.definition.movement.move_speed * deltaSeconds;

  while (enemy.progressToNextTile >= 1 && !enemy.leaked) {
    enemy.progressToNextTile -= 1;
    enemy.pathIndex += 1;

    if (enemy.pathIndex >= pathLength) {
      enemy.leaked = true;
      return 1;
    }
  }

  return 0;
}

export function advanceEnemies(state: CombatRuntimeState, deltaSeconds: number): number {
  let leakedThisTick = 0;

  for (const enemy of state.enemies) {
    leakedThisTick += advanceEnemy(enemy, deltaSeconds, state.path.length);
  }

  state.leakedEnemyCount += leakedThisTick;
  return leakedThisTick;
}
