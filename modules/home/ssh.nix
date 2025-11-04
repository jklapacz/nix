{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:

let
  hostname = osConfig.networking.hostName or "";
  isWork = hostname == "Shadowfax";
  personalEmail = "kubaklapacz@gmail.com";
  workEmail = "jakub@gordiansoftware.com";
in
{
  # Generate SSH keys if they don't exist
  home.activation.generateSSHKeys = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    if isWork then
      ''
        if [ ! -f "$HOME/.ssh/id_ed25519_personal" ]; then
          $DRY_RUN_CMD ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -C "${personalEmail}" -f "$HOME/.ssh/id_ed25519_personal" -N ""
        fi
        if [ ! -f "$HOME/.ssh/id_ed25519_work" ]; then
          $DRY_RUN_CMD ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -C "${workEmail}" -f "$HOME/.ssh/id_ed25519_work" -N ""
        fi
      ''
    else
      ''
        if [ ! -f "$HOME/.ssh/id_ed25519_personal" ]; then
          $DRY_RUN_CMD ${pkgs.openssh}/bin/ssh-keygen -t ed25519 -C "${personalEmail}" -f "$HOME/.ssh/id_ed25519_personal" -N ""
        fi
      ''
  );

  home.file.".ssh/config".text =
    if true then
      ''
        # Default GitHub account (work)
        Host github.com
          HostName github.com
          User git
          IdentityFile ~/.ssh/id_ed25519_work

        # Personal GitHub account
        Host github-personal
          HostName github.com
          User git
          IdentityFile ~/.ssh/id_ed25519_personal

        Host legacy-laptop-local
          HostName 192.168.1.108
          User gordian
          IdentityFile ~/.ssh/id_ed25519_work
      ''
    else
      ''
        # Personal GitHub account
        Host github.com
          HostName github.com
          User git
          IdentityFile ~/.ssh/id_ed25519_personal
        Host cortex
          HostName cortex.local
          User root
      '';
}
