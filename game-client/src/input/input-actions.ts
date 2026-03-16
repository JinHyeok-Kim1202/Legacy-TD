export type InputAction =
  | "select_cell"
  | "select_storage_unit"
  | "move_unit"
  | "merge_selected"
  | "start_round"
  | "pause_game";

export interface InputCommand {
  action: InputAction;
  targetRow?: number;
  targetCol?: number;
  unitId?: string;
}
