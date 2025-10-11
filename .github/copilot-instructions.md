## Quick context for AI coding agents

This repository is an AI-first CLI tool and template collection for creating Chinese novels using a Spec-Driven Development (SDD) workflow. Key components:

- `src/cli.ts` — primary CLI entry (commands: `init`, `upgrade`, etc.). Look here for how projects are bootstrapped and how AI agent types map to filesystem layout.
- `package.json` — build/dev scripts. `npm run build` compiles TypeScript; `npm run build:commands` generates per-agent command files from templates.
- `dist/*` — build artifacts containing pre-generated agent command sets (copied into user projects by `init`).
- `.specify/`, `spec/`, `stories/` — runtime project layout produced by `novel init`.
- `other/spec-kit/AGENTS.md` — long-form guidance and agent conventions; use it as authoritative reference when adding new agents.

Keep instructions short and concrete: reference the exact file and function you changed and prefer small, self-contained edits.

## High-level architecture notes

- The CLI bootstraps a project by copying built artifacts from the package root (`dist/<agent>`) into the target project and creating `.specify/*` scaffolding (`src/cli.ts`, copy logic around `sourceMap`).
- Agent configuration is agent-centric: directories like `.claude/commands`, `.gemini/commands`, `.cursor/commands` are created and populated during `novel init`.
- Agent metadata and behavioral decisions are centered in the Spec Kit patterns documented in `other/spec-kit/AGENTS.md`. When adding agents, prefer updating `AGENT_CONFIG` (in the spec-kit implementation) and the `scripts/*` update tooling.

## Common developer workflows (how to run / build / test)

- Local development: `npm run dev` (runs `tsx src/cli.ts`) — fast way to iterate on CLI behavior without building.
- Build: `npm run build` (TypeScript -> `dist/`), then `npm run build:commands` to regenerate per-agent command files. `prepare` and `prepublishOnly` call both.
- If an `init` action warns that a dist artifact is missing, run `npm run build:commands` and re-run the command.

Files to check when changes affect agent commands or templates:
- `scripts/build/generate-commands.sh` — generator used by `npm run build:commands`.
- `templates/` and `dist/<agent>/` — where generated templates and command files live.

## Project-specific conventions and gotchas (do not invent)

- Use the actual CLI executable name as the agent key (e.g., `cursor-agent`, not `cursor`). This is enforced across scripts and the tool-checking logic (`other/spec-kit/AGENTS.md`).
- Command formats differ per agent:
  - Markdown prompts (Claude, Cursor, opencode): `$ARGUMENTS`, `{SCRIPT}` placeholders.
  - TOML prompts (Gemini, Qwen): `{{args}}` placeholders and `prompt` keys.
  See `other/spec-kit/AGENTS.md` for exact examples and `src/cli.ts` helpers `generateMarkdownCommand` / `generateTomlCommand`.
- When adding files to `dist/` for an agent, update `scripts/*/update-agent-context.(sh|ps1)` and `.github/workflows/scripts/create-release-packages.sh` to include the agent packaging case.

## What to change when adding or updating an agent

1. Update agent metadata in the single source of truth (AGENT_CONFIG in spec-kit implementation).
2. Update `src/cli.ts` help text (the `--ai` option) and any `switch` that creates AI directories.
3. Add generation support in `scripts/build/generate-commands.sh` (and release packaging scripts).
4. Add or update templates in `templates/` and run `npm run build:commands`.
5. Update `other/spec-kit/scripts/*` (bash + PowerShell) that collect agent context files for README/CLAUDE/Copilot docs.

## Examples (explicit references)

- To regenerate commands after editing a template: run `npm run build:commands`. If a CLI `init` cannot find `dist/<agent>`, this is usually the fix.
- If you change how an agent is referenced, search `src/cli.ts` for the `sourceMap` and the `switch(options.ai)` branch that maps `--ai` values to directories.
- If adding CLI detection or validation for a new agent, follow the `requires_cli` pattern described in `other/spec-kit/AGENTS.md` and update the scripts `scripts/bash/update-agent-context.sh` and `scripts/powershell/update-agent-context.ps1`.

## Safety and style

- Small, focused patches are preferred. When editing templates, preserve frontmatter and `{SCRIPT}` placeholders used by the generators.
- Prefer modifying `templates/` and running the generator instead of hand-editing `dist/` files.

## Quick file map (start here)

- `src/cli.ts` — CLI behavior and project bootstrap
- `src/ai-interface.ts` — AI-facing APIs and method-selection logic
- `scripts/build/generate-commands.sh` — command generator used in CI and local builds
- `other/spec-kit/AGENTS.md` — agent conventions and integration steps (authoritative)
- `package.json` — build/dev scripts (`dev`, `build`, `build:commands`, `prepare`)

If anything in this instruction page is unclear or you want more examples (for example: a sample TOML command converted from a Markdown command in this codebase), tell me which area to expand and I will iterate. 
