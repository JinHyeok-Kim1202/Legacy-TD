# Legacy TD Project Rules

## Context
- This project is `Legacy TD`, a solo-developed 3D grid-based tower defense game.
- Target platforms are PC and mobile.
- Maintainability and clear data contracts matter more than short-term speed.

## Working Rules
- Keep gameplay rules in `game-shared/`.
- Keep platform-specific code in `game-client/src/platform/pc` and `game-client/src/platform/mobile`.
- Keep UI code separate from gameplay rules where practical.
- Keep tooling and content pipelines in `game-tools/`.
- Prefer additive, migration-friendly data changes.
- Do not change save-related contracts carelessly.

## Current Design Constraints
- The board is always a fixed 5x5 grid.
- Enemies move only along the outer ring path in a single direction.
- The player goal is to survive 100 rounds, then continue into endless mode.
- The loss condition is difficulty-specific leaked enemy count.
- Round rewards, unit definitions, recipes, waves, and difficulty settings must stay data-driven.

## Code Quality
- Prefer readable names and focused modules.
- Avoid mixing runtime logic with content data.
- Add comments only when the logic is not obvious.


## Session Handoff Commit Policy
- This repository must stay usable across sessions from commit history alone.
- Before ending a work session, create a detailed git commit message that summarizes:
  - changed systems
  - key files
  - gameplay/data/UI/runtime impact
  - verification performed
  - remaining risks and recommended next step
- Prefer commit messages that function as a session handoff, not just a short label.
- Keep `.gitignore` current so only durable project state is committed.
