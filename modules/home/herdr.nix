{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Register the worktree-hook plugin (modules/herdr/plugin) with herdr on
  # every activation. Linking is idempotent — re-linking an already-linked
  # plugin updates it in place — and persists in herdr's plugins.json, which
  # herdr reloads on startup. The link points at the repo checkout (not the
  # nix store) so hook-script edits take effect without a rebuild.
  #
  # The CLI needs the herdr server's unix socket; if herdr isn't running the
  # link fails, so warn instead of aborting activation — it will be retried
  # on the next switch, or manually via `herdr plugin link`.
  home.activation.linkHerdrPlugin = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.herdr}/bin/herdr plugin link \
      ${config.home.homeDirectory}/.config/nix/modules/herdr/plugin >/dev/null \
      || echo "warning: herdr plugin link failed (is herdr running?); retried on next activation"
  '';
}
