import type { OwnedUnitInstance, PlayerRosterState } from "../../types";
import { createBoardUnitState, placeUnitOnBoard, removeUnitFromBoard } from "./board-placement";
import { addUnitToStorage, createStorageState, removeUnitFromStorage } from "./storage-state";

export function createPlayerRosterState(boardRows: number, boardCols: number, storageCapacity: number): PlayerRosterState {
  return {
    storage: createStorageState(storageCapacity),
    board: createBoardUnitState(boardRows, boardCols),
  };
}

export function addOwnedUnitToRosterStorage(roster: PlayerRosterState, unit: OwnedUnitInstance): boolean {
  return addUnitToStorage(roster.storage, unit);
}

export function moveUnitFromStorageToBoard(
  roster: PlayerRosterState,
  instanceId: string,
  position: [number, number]
): boolean {
  const unit = removeUnitFromStorage(roster.storage, instanceId);
  if (!unit) {
    return false;
  }

  const placed = placeUnitOnBoard(roster.board, unit, position);
  if (!placed) {
    addUnitToStorage(roster.storage, unit);
    return false;
  }

  return true;
}

export function moveUnitFromBoardToStorage(roster: PlayerRosterState, instanceId: string): boolean {
  const occupant = roster.board.occupants.find((entry) => entry.unit.instanceId === instanceId);
  if (!occupant) {
    return false;
  }

  const originalPosition = occupant.position;
  const unit = removeUnitFromBoard(roster.board, instanceId);
  if (!unit) {
    return false;
  }

  const stored = addUnitToStorage(roster.storage, unit);
  if (!stored) {
    placeUnitOnBoard(roster.board, unit, originalPosition);
    return false;
  }

  return true;
}
