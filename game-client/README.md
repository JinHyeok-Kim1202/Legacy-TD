# Legacy TD Client

This folder holds runtime client code and platform-facing presentation code.

The current scaffold is engine-neutral on purpose:
- `src/app` wires the runtime shell
- `src/scenes` holds scene-level orchestration
- `src/ui` holds HUD contracts
- `src/input` holds shared input contracts
- `src/platform/pc` and `src/platform/mobile` hold platform adapters
- `src/presentation` holds view-model and asset registry code

When the engine is chosen later, these files can either wrap the engine runtime or be migrated behind engine-specific adapters.
