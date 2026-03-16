import type { InputAction } from "../../input/input-actions";

export interface MobileGestureBinding {
  gesture: "tap" | "double_tap" | "drag" | "long_press";
  action: InputAction;
}

export const defaultMobileBindings: MobileGestureBinding[] = [
  { gesture: "tap", action: "select_cell" },
  { gesture: "drag", action: "move_unit" },
  { gesture: "double_tap", action: "merge_selected" },
  { gesture: "long_press", action: "pause_game" },
];
