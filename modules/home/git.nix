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
  programs.git = {
    enable = true;
    userName = "Jakub Klapacz";
    userEmail = if isWork then workEmail else personalEmail;
    ignores = [ ".DS_STORE" ];
    aliases = {
      # Short, pretty log with graph and refs
      lg = ''
        log --graph \
          --pretty=format:'%C(yellow)%h%Creset -%C(green)%aN%Creset - %C(blue)%ar%Creset %C(auto)%d %Creset%s'
      '';

      lga = "log --graph --all --decorate --oneline";

      # Detailed log with date, commit message, and stats
      lgd = ''
        log --pretty=format:'%C(yellow)%h %Creset| %C(green)%an %Creset| %C(blue)%ar %Creset| %s' --stat
      '';
    };
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };

  home.file = {
    ".gitconfig".text =
      if isWork then
        ''
          [user]
            name = Jakub Klapacz
            email = ${workEmail}

            [includeIf "gitdir:~/.config/nix/"]
              path = ~/.gitconfig-personal

            [includeIf "gitdir:~/dev/novnc-fork/"]
              path = ~/.gitconfig-personal

            [includeIf "gitdir:~/dev/terraform-provider-postgresql/"]
              path = ~/.gitconfig-personal

            [includeIf "gitdir:~/dev/cua/"]
              path = ~/.gitconfig-personal

            [includeIf "gitdir:~/dev/devenv-templates/"]
              path = ~/.gitconfig-personal

            [includeIf "gitdir:~/dev/bootstrap/"]
              path = ~/.gitconfig-personal

            [includeIf "gitdir:~/dev/window-manager/"]
              path = ~/.gitconfig-personal

            [includeIf "gitdir:~/dev/aol/"]
              path = ~/.gitconfig-personal

            [includeIf "gitdir:~/dev/rusty/"]
              path = ~/.gitconfig-personal

            [includeIf "gitdir:~/dev/prexler/"]
              path = ~/.gitconfig-personal
        ''
      else
        ''
          [user]
            name = Jakub Klapacz
            email = ${personalEmail}
        '';
  }
  // lib.optionalAttrs isWork {
    ".gitconfig-personal".text = ''
      [user]
        name = Jakub Klapacz
        email = ${personalEmail}
    '';
  };
}
