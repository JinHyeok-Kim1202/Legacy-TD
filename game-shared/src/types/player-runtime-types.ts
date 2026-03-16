import type { GridCoordinate } from "./board-types";
import type { UnitDefinition } from "./unit-types";

export interface OwnedUnitInstance {
  instanceId: string;
  definition: UnitDefinition;
}

export interface StorageSlot {
  index: number;
  unit: OwnedUnitInstance | null;
}

export interface StorageState {
  capacity: number;
  slots: StorageSlot[];
}

export interface BoardOccupant {
  unit: OwnedUnitInstance;
  position: GridCoordinate;
}

export interface BoardUnitState {
  rows: number;
  cols: number;
  occupants: BoardOccupant[];
}

export interface PlayerRosterState {
  storage: StorageState;
  board: BoardUnitState;
}
