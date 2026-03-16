import type { BoardUnitState, GridCoordinate, OwnedUnitInstance } from "../../types";

export function createBoardUnitState(rows: number, cols: number): BoardUnitState {
  return {
    rows,
    cols,
    occupants: [],
  };
}

export function isValidBoardCoordinate(board: BoardUnitState, position: GridCoordinate): boolean {
  const [row, col] = position;
  return row >= 0 && row < board.rows && col >= 0 && col < board.cols;
}

export function getBoardOccupantAt(board: BoardUnitState, position: GridCoordinate) {
  return board.occupants.find((occupant) => occupant.position[0] === position[0] && occupant.position[1] === position[1]) ?? null;
}

export function placeUnitOnBoard(board: BoardUnitState, unit: OwnedUnitInstance, position: GridCoordinate): boolean {
  if (!isValidBoardCoordinate(board, position)) {
    return false;
  }

  if (getBoardOccupantAt(board, position)) {
    return false;
  }

  board.occupants.push({ unit, position });
  return true;
}

export function removeUnitFromBoard(board: BoardUnitState, instanceId: string): OwnedUnitInstance | null {
  const index = board.occupants.findIndex((occupant) => occupant.unit.instanceId === instanceId);
  if (index < 0) {
    return null;
  }

  const [removed] = board.occupants.splice(index, 1);
  return removed.unit;
}

export function moveBoardUnit(board: BoardUnitState, instanceId: string, nextPosition: GridCoordinate): boolean {
  if (!isValidBoardCoordinate(board, nextPosition) || getBoardOccupantAt(board, nextPosition)) {
    return false;
  }

  const occupant = board.occupants.find((entry) => entry.unit.instanceId === instanceId);
  if (!occupant) {
    return false;
  }

  occupant.position = nextPosition;
  return true;
}
