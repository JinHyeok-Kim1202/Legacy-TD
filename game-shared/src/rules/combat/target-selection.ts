import type { EnemyRuntime, GridCoordinate, PlacedUnitRuntime } from "../../types";

function distanceBetween(a: GridCoordinate, b: GridCoordinate): number {
  const rowDelta = a[0] - b[0];
  const colDelta = a[1] - b[1];
  return Math.sqrt(rowDelta * rowDelta + colDelta * colDelta);
}

function getEnemyTile(enemy: EnemyRuntime, path: GridCoordinate[]): GridCoordinate {
  return path[Math.min(enemy.pathIndex, path.length - 1)] ?? path[0] ?? [0, 0];
}

function getCandidates(unit: PlacedUnitRuntime, enemies: EnemyRuntime[], path: GridCoordinate[]): EnemyRuntime[] {
  return enemies.filter((enemy) => {
    if (enemy.defeated || enemy.leaked) {
      return false;
    }

    const enemyPosition = getEnemyTile(enemy, path);
    return distanceBetween(unit.position, enemyPosition) <= unit.definition.attack.range;
  });
}

export function selectTarget(unit: PlacedUnitRuntime, enemies: EnemyRuntime[], path: GridCoordinate[]): EnemyRuntime | null {
  const candidates = getCandidates(unit, enemies, path);
  if (candidates.length === 0) {
    return null;
  }

  const { targeting } = unit.definition.attack;

  if (targeting === "first") {
    return candidates.reduce((best, current) => (current.pathIndex > best.pathIndex ? current : best));
  }

  if (targeting === "last") {
    return candidates.reduce((best, current) => (current.pathIndex < best.pathIndex ? current : best));
  }

  if (targeting === "strongest") {
    return candidates.reduce((best, current) => (current.currentHp > best.currentHp ? current : best));
  }

  if (targeting === "weakest") {
    return candidates.reduce((best, current) => (current.currentHp < best.currentHp ? current : best));
  }

  return candidates.reduce((best, current) => {
    const bestDistance = distanceBetween(unit.position, getEnemyTile(best, path));
    const currentDistance = distanceBetween(unit.position, getEnemyTile(current, path));
    return currentDistance < bestDistance ? current : best;
  });
}
