#!/usr/bin/env bash
# Fired by herdr on worktree.created (see herdr-plugin.toml).
# Runs with cwd = this plugin directory; event details arrive via env vars.
#
# What it does, in order:
#   1. Copies gitignored local config from the main checkout into the new
#      worktree, per the repo's .worktreeinclude (git exclude-pattern syntax).
#   2. Runs REPO_ROOT/.herdr/on-worktree-create.sh if the repo provides one,
#      with cwd = the new worktree and this env contract:
#        HERDR_WORKTREE_PATH, HERDR_REPO_ROOT, HERDR_WORKTREE_BRANCH
set -euo pipefail

# The herdr app may spawn hooks with a minimal PATH; make nix tools reachable.
export PATH="/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:/usr/bin:/bin:$PATH"

log_dir="${HERDR_PLUGIN_STATE_DIR:-$HOME/.local/state/herdr-worktree-hook}"
mkdir -p "$log_dir"
log_file="$log_dir/events.log"
# stdout is also captured by herdr (herdr plugin log list)
log() { printf '%s\n' "$*" | tee -a "$log_file"; }

event_json="${HERDR_PLUGIN_EVENT_JSON:-}"
if [ -z "$event_json" ]; then
  log "worktree-hook: no HERDR_PLUGIN_EVENT_JSON, nothing to do"
  exit 0
fi

worktree_path=$(jq -r '.data.worktree.path // empty' <<<"$event_json")
repo_root=$(jq -r '.data.workspace.worktree.repo_root // empty' <<<"$event_json")
branch=$(jq -r '.data.worktree.branch // empty' <<<"$event_json")

if [ -z "$worktree_path" ] || [ ! -d "$worktree_path" ]; then
  log "worktree-hook: no usable worktree path in event: $event_json"
  exit 0
fi
if [ -z "$repo_root" ]; then
  repo_root=$(dirname "$(git -C "$worktree_path" rev-parse --path-format=absolute --git-common-dir)")
fi

log "worktree-hook: $(date '+%Y-%m-%d %H:%M:%S') worktree=$worktree_path repo=$repo_root branch=${branch:-?}"

# 1. Copy gitignored local config (e.g. .env) listed in .worktreeinclude,
#    using git's own pattern matching against the main checkout.
if [ -f "$repo_root/.worktreeinclude" ]; then
  while IFS= read -r -d '' file; do
    mkdir -p "$worktree_path/$(dirname "$file")"
    cp "$repo_root/$file" "$worktree_path/$file"
    log "worktree-hook:   copied $file"
  done < <(git -C "$repo_root" ls-files --others --ignored \
             --exclude-from="$repo_root/.worktreeinclude" -z)
fi

# 2. Hand off to the repo's own lifecycle hook, if it has one.
repo_hook="$repo_root/.herdr/on-worktree-create.sh"
if [ -f "$repo_hook" ]; then
  log "worktree-hook: running $repo_hook"
  if (cd "$worktree_path" &&
        HERDR_WORKTREE_PATH="$worktree_path" \
        HERDR_REPO_ROOT="$repo_root" \
        HERDR_WORKTREE_BRANCH="$branch" \
        bash "$repo_hook") >>"$log_file" 2>&1; then
    log "worktree-hook: repo hook succeeded"
  else
    log "worktree-hook: repo hook FAILED (exit $?), see $log_file"
    exit 1
  fi
else
  log "worktree-hook: no .herdr/on-worktree-create.sh in $repo_root, done"
fi
