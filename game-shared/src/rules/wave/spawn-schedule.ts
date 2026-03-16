import type { EnemyDefinition, EnemyRuntime, WaveDefinition } from "../../types";
import { createEnemyRuntime } from "../combat/combat-tick";

export interface ScheduledEnemySpawn {
  spawnTimeSeconds: number;
  enemyDefinitionId: string;
  instanceId: string;
}

export interface WaveSpawnSchedule {
  round: number;
  events: ScheduledEnemySpawn[];
}

export function createWaveSpawnSchedule(wave: WaveDefinition): WaveSpawnSchedule {
  const events: ScheduledEnemySpawn[] = [];
  let runningTimeSeconds = 0;
  let counter = 0;

  for (const entry of wave.entries) {
    for (let index = 0; index < entry.count; index += 1) {
      counter += 1;
      events.push({
        spawnTimeSeconds: runningTimeSeconds,
        enemyDefinitionId: entry.enemy_id,
        instanceId: `enemy_${wave.round}_${counter}`,
      });
      runningTimeSeconds += entry.spawn_interval;
    }
  }

  return {
    round: wave.round,
    events,
  };
}

export function spawnScheduledEnemies(
  elapsedSeconds: number,
  schedule: WaveSpawnSchedule,
  spawnedInstanceIds: Set<string>,
  enemyDefinitions: Map<string, EnemyDefinition>
): EnemyRuntime[] {
  const spawns: EnemyRuntime[] = [];

  for (const event of schedule.events) {
    if (spawnedInstanceIds.has(event.instanceId) || event.spawnTimeSeconds > elapsedSeconds) {
      continue;
    }

    const definition = enemyDefinitions.get(event.enemyDefinitionId);
    if (!definition) {
      continue;
    }

    spawnedInstanceIds.add(event.instanceId);
    spawns.push(
      createEnemyRuntime({
        instanceId: event.instanceId,
        definition,
      })
    );
  }

  return spawns;
}
