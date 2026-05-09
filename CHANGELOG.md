# Changelog

All notable changes to this project will be documented in this file.

## 0.3.0 - 2026-05-09

### Breaking Changes
- Migrated from Claude Code to pi as the coding agent harness
- Replaced Claude-specific `claude` CLI calls with `pi --mode json`
- Rewrote `ralph-format.sh` to parse pi's JSON event stream format
- Removed `.claude/` settings in favor of `.pi/settings.json`
- Replaced `.claude-plugin/` marketplace with pi package manifest (`package.json`)
- Updated all documentation and skills to reference pi instead of Claude
- Changed references from CLAUDE.md to AGENTS.md throughout

### Migration
- Install now uses `pi install git:github.com/mcwalrus/choo-choo-ralph`
- Prerequisites now require pi CLI instead of Claude Code CLI
- All formula files unchanged (beads-compatible, no Claude dependency)

## 0.2.1 - 2026-03-12

### Fixes
- Restructure to monorepo marketplace with relative paths to fix recursive loop during plugin installation
- Include plugin.json in Claude Plugin version detection for release workflow

## 0.2.0 - 2026-01-28

### Features
- Add parallel execution support for running multiple Ralph instances without conflicts