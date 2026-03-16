import type { InputAction } from "../../input/input-actions";

export interface PcInputBinding {
  key: string;
  action: InputAction;
}

export const defaultPcBindings: PcInputBinding[] = [
  { key: "Enter", action: "start_round" },
  { key: "M", action: "merge_selected" },
  { key: "Escape", action: "pause_game" },
];
