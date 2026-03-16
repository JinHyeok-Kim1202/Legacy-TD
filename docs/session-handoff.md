# Legacy TD Session Handoff

## Project Identity
- Name: `Legacy TD`
- Genre: grid-based tower defense with a fixed 2.5D isometric presentation
- Engine: `Godot 4`
- Project root: `C:\Users\Jinhyeok\Downloads\oh-my\legacy-td`
- Godot project root: `game-client/godot`

## Current Core Direction
- The board is a fixed `5x5` battlefield.
- Enemies move on the outer ring path and now loop continuously instead of leaking out after one lap.
- Defeat is currently based on `max_active_enemies` for the selected difficulty, not on leaks.
- The run starts with a difficulty selection screen.
- After difficulty selection, rounds auto-start every `60` seconds.
- The first auto round also starts after `60` seconds.
- Target survival length is currently `60` rounds.
- Visual direction is `2.5D billboard sprite` for units and enemies.
- Shared gameplay data stays in `game-shared/data`.
- Godot runtime/presentation stays in `game-client/godot`.

## What Changed In This Session

### 1. Godot Runtime Is No Longer A Scaffold
- Shared JSON is loaded by Godot through:
  - `game-client/godot/scripts/runtime/shared_data_loader.gd`
- Main runtime/state is managed in:
  - `game-client/godot/scripts/autoload/game_state.gd`
- Combat exists in Godot and includes:
  - enemy spawning
  - enemy movement
  - unit targeting
  - damage application
  - enemy HP reduction
  - enemy defeat and gold reward
- Merge exists in Godot and is driven from shared recipes:
  - `game-client/godot/scripts/runtime/merge_runtime.gd`

### 2. Presentation / Scene State
- Main scene:
  - `game-client/godot/scenes/main/Main.tscn`
- HUD:
  - `game-client/godot/scenes/ui/MainHud.tscn`
  - `game-client/godot/scripts/ui/main_hud.gd`
- Board:
  - `game-client/godot/scenes/board/GridBoard.tscn`
  - `game-client/godot/scripts/board/grid_board.gd`
- The board is shown in a fixed orthographic 2.5D view.
- The board has been rotated so it reads more like a square battlefield in the current camera framing.
- Units and enemies are now built through a dedicated billboard factory:
  - `game-client/godot/scripts/presentation/actor_view_factory.gd`

### 3. Unit / Enemy Visuals
- Units are no longer temporary 3D primitive stacks created directly in `grid_board.gd`.
- Units and enemies are now created via `ActorViewFactory`.
- The project is set up for billboard-sprite character presentation.
- Current billboard visuals use placeholder generated textures, not final art assets.
- Unit rarity colors were updated to:
  - common: white
  - rare: blue
  - unique: purple
  - legendary: red
  - transcendent: mint
  - immortal: orange
  - god: sky blue
  - liberator: green

### 4. HUD / Play Loop State
- Storage is shown as a grid inventory instead of a plain list.
- Merge options are shown for the currently selected anchor unit.
- Invalid merge recipes are shown disabled.
- Range visualization exists:
  - clicking a placed unit shows a green range circle
  - clicking elsewhere clears it
- Enemy HP is shown as a color-changing bar:
  - green -> yellow -> orange -> red

### 5. Progression / Difficulty / Round Flow
- Difficulty selection exists and gates the run start.
- Difficulties now use `max_active_enemies`.
- Countdown and top-center warning UI exist:
  - countdown to next round
  - boss incoming warning
  - active enemy warning
- Round start is automatic on a 60-second interval.

### 6. Story Boss / Mission Boss Systems
- New progression data was added:
  - `game-shared/data/progression/story_bosses.json`
  - `game-shared/data/progression/mission_bosses.json`
- Story lane exists in runtime and HUD:
  - left-side story boss area
  - 3 horizontal story unit slots
  - a stationary story semi-boss with 15 stages
- Story boss HP increases by stage.
- Story slots auto-attack the story boss.
- Mission boss system exists in runtime and HUD:
  - mission bosses unlock after clearing corresponding round bosses
  - current unlock rounds: 10 / 20 / 30 / 40
  - summon cooldown: 5 minutes
  - one active mission boss at a time

### 7. Boss / Reward Data
- Round boss data now includes 10 / 20 / 30 / 40 / 50 bosses:
  - `game-shared/data/enemies/bosses.json`
- Story and mission rewards were changed to draw-based reward packages:
  - `bonus_common_draws`
  - `bonus_rare_draws`
  - `bonus_unique_draws`
  - `bonus_legendary_draws`
- Maximum direct rarity reward is now `legendary`.
- `GameState` reward handling was updated to consume those four draw fields.

### 8. Units / Recipes Data Was Rebuilt From unit.txt
- Source design document:
  - `unit.txt`
- Actual game data regenerated from that document:
  - `game-shared/data/units/units.json`
  - `game-shared/data/progression/recipes.json`
- `units.json` is now sorted by rarity for easier reading.
- The current units/recipes reflect:
  - Korean display names
  - rarity tiers from common to liberator
  - physical / magic attack type from `unit.txt`
  - recipe graph generated from `unit.txt`

## Important Current Files
- Runtime state:
  - `game-client/godot/scripts/autoload/game_state.gd`
- Shared JSON loader:
  - `game-client/godot/scripts/runtime/shared_data_loader.gd`
- Merge runtime:
  - `game-client/godot/scripts/runtime/merge_runtime.gd`
- Round runtime:
  - `game-client/godot/scripts/runtime/round_runtime.gd`
- Combat runtime:
  - `game-client/godot/scripts/runtime/combat_runtime.gd`
- Billboard actor factory:
  - `game-client/godot/scripts/presentation/actor_view_factory.gd`
- Board scene logic:
  - `game-client/godot/scripts/board/grid_board.gd`
- HUD logic:
  - `game-client/godot/scripts/ui/main_hud.gd`
- Shared units:
  - `game-shared/data/units/units.json`
- Shared recipes:
  - `game-shared/data/progression/recipes.json`
- Story bosses:
  - `game-shared/data/progression/story_bosses.json`
- Mission bosses:
  - `game-shared/data/progression/mission_bosses.json`
- Round bosses:
  - `game-shared/data/enemies/bosses.json`

## Validation Status
- Data validation command:

```bash
cd C:\Users\Jinhyeok\Downloads\oh-my\legacy-td
npm run validate:data
```

- Last known result: `passed`

Notes:
- Godot headless runs still print dummy renderer mesh warnings (`mesh_get_surface_count`), but recent script/data changes were still able to load without new parse failures.
- TypeScript compile validation was not run here.
- Some terminal views may display Korean text with mojibake depending on console encoding, but files were written as UTF-8.

## Known Risks / Things To Verify Next
- The new `units.json` / `recipes.json` generated from `unit.txt` need real in-game merge and reward-flow playtesting.
- Story boss / mission boss systems were wired in one large pass and need live Godot verification end-to-end:
  - story slot placement
  - story boss damage and stage progression
  - mission boss unlock and cooldown
  - reward payout
- Reward pacing for `60` rounds should be verified in real play, especially for the goal of reaching multiple terminal-tier units.
- Billboard visuals are still placeholder-generated textures, not final sprite assets.

## Recommended Next Task
- Verify the currently integrated systems in the Godot editor, in this order:
  1. difficulty select
  2. 60-second auto-round countdown
  3. storage placement
  4. merge enable/disable behavior
  5. round boss clear rewards
  6. story lane placement and story boss stage progression
  7. mission boss unlock / summon / cooldown / rewards
  8. newly generated unit and recipe data behaving correctly

## Constraints To Keep
- Keep gameplay rules/data in `game-shared`.
- Keep Godot-only presentation/runtime in `game-client/godot`.
- Preserve additive data changes where possible.
- Do not silently revert the new `unit.txt -> units.json / recipes.json` mapping without checking downstream references.
- Keep PC/mobile separation intact for future input work.

## Quick Restart Prompt
Use this in the next session:

```text
Continue Legacy TD from docs/session-handoff.md. Use Godot 4 under game-client/godot. Keep gameplay rules/data in game-shared. We already have: 60-round auto-start loop with difficulty selection, looping enemies, active-enemy-limit defeat, storage/merge, billboard unit/enemy presentation, story boss lane with 3 slots and 15 stages, mission bosses unlocked from round bosses, and unit.txt applied into units.json/recipes.json. Start by verifying the integrated systems in Godot and then fix whatever is broken in story boss / mission boss / merge / reward flow.
```
