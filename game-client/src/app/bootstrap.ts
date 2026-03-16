import { createGameClient } from "./game-client";
import { defaultGameClientConfig } from "./game-client-config";

export function bootstrapGameClient() {
  return createGameClient(defaultGameClientConfig);
}
