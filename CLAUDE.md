# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Nix configuration repository for macOS systems using nix-darwin and home-manager. It manages system-level and user-level configurations declaratively for two Darwin hosts: "Shadowfax" (work) and "Anduril" (personal).

## Commands

### Building and Applying Configuration
```bash
# Primary command to rebuild and switch configuration (requires sudo)
sudo darwin-rebuild switch --flake ~/.config/nix

# Using convenience alias (defined in shell config)
switch

# Using initialization script (may need sudo)
./init.sh
```

### Common Development Tasks
```bash
# Update flake inputs
nix flake update

# Check flake configuration
nix flake check

# Show flake outputs
nix flake show
```

## Architecture

### Repository Structure
- `flake.nix` - Central configuration defining all system settings
- `hosts/darwin/` - Host-specific Darwin configurations
- `modules/` - Custom packages and configuration modules
  - `biome/` - Biome formatter package overlay
  - `claude/` - Claude CLI tool package overlay
  - `cursor.nix` - Cursor editor configuration
  - `lume.nix` - Lume VM management tool
- `dock/` - macOS dock configuration module

### Key Concepts
1. **Multi-host Configuration**: Configurations are split between work ("Shadowfax") and personal ("Anduril") machines
2. **Modular Design**: Features are organized into separate modules that can be conditionally enabled
3. **Package Management**: 
   - CLI tools via Nix packages
   - GUI applications via Homebrew casks (managed by nix-homebrew)
   - Custom packages via overlays
4. **VM Detection**: Automatically detects VM environments and adjusts Docker installation

### Configuration Flow
1. `flake.nix` imports host-specific configurations from `hosts/darwin/`
2. Host configurations import and configure various modules
3. home-manager manages user-level settings while nix-darwin manages system settings
4. Custom overlays provide additional packages not in nixpkgs

## Important Notes

- When modifying configurations, always test with `sudo darwin-rebuild switch --flake ~/.config/nix`
- home-manager creates backup files (`.backup`) when updating configurations
- Git is configured with conditional includes based on directory path for work/personal separation
- The repository uses Nix flakes with experimental features enabled
- Claude CLI auto-updater is disabled via `CLAUDE_UPDATE_CHECK=0` environment variable