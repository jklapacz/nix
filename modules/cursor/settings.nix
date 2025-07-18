# Cursor editor settings
{ pkgs, user }:
{
  extensions = with pkgs.vscode-marketplace; [
    alefragnani.project-manager
    asvetliakov.vscode-neovim
    charliermarsh.ruff
    eamodio.gitlens
    golang.go
    jnoortheen.nix-ide
    mkhl.direnv
    ms-python.debugpy
    ms-python.python
    ms-python.vscode-pylance
    textualize.textual-syntax-highlighter
    editorconfig.editorconfig
    denoland.vscode-deno
  ];

  settings = {
    # Appearance
    "workbench.colorTheme" = "Monokai";
    "editor.fontFamily" = "'Hack Nerd Font', 'FiraCode Nerd Font', '0xProto Nerd Font', Menlo, Monaco, 'Courier New', monospace";
    "editor.fontSize" = 14;
    "editor.lineNumbers" = "relative";
    
    # UI
    "window.commandCenter" = 1;
    
    # Extensions
    "extensions.verifySignature" = false;
    "extensions.experimental.affinity" = {
      "asvetliakov.vscode-neovim" = 1;
    };
    
    # Project Manager
    "projectManager.git.baseFolders" = [
      "/Users/${user}/dev"
      "/Users/${user}/.config"
    ];
    
    # Files
    "files.insertFinalNewline" = true;
    
    # Editor
    "editor.formatOnSave" = true;
    "editor.codeActionsOnSave" = {
      "source.fixAll.biome" = "always";
      "source.organizeImports.biome" = "always";
    };
    
    # Language-specific formatters
    "[json]" = {
      "editor.defaultFormatter" = "biomejs.biome";
    };
    "[jsonc]" = {
      "editor.defaultFormatter" = "biomejs.biome";
    };
    "[javascript]" = {
      "editor.defaultFormatter" = "biomejs.biome";
      "source.organizeImports.biome" = "explicit";
    };
    "[typescript]" = {
      "editor.defaultFormatter" = "biomejs.biome";
      "source.organizeImports.biome" = "explicit";
    };
    "[javascriptreact]" = {
      "editor.defaultFormatter" = "biomejs.biome";
      "source.organizeImports.biome" = "explicit";
    };
    "[typescriptreact]" = {
      "editor.defaultFormatter" = "biomejs.biome";
      "source.organizeImports.biome" = "explicit";
    };
    "[python]" = {
      "editor.defaultFormatter" = "charliermarsh.ruff";
      "editor.formatOnSave" = true;
      "editor.codeActionsOnSave" = {
        "source.fixAll.ruff" = "explicit";
        "source.organizeImports.ruff" = "explicit";
      };
    };
  };
}