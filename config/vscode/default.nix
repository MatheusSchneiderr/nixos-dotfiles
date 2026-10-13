{ config, pkgs, ... }:
{
  stylix.targets.vscode.enable = false;

  xdg.configFile."Code/User" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/vscode/";
    recursive = true;
  };

  programs.vscode = {
    mutableExtensionsDir = false;
    profiles.default = {
      extensions = (with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        ms-vscode-remote.remote-ssh
        ms-vscode-remote.remote-ssh-edit
        ms-dotnettools.vscode-dotnet-runtime
        ms-dotnettools.csharp
        ms-dotnettools.csdevkit
        ionide.ionide-fsharp
        bmewburn.vscode-intelephense-client
        tamasfe.even-better-toml
      ]) ++ [
        (pkgs.vscode-utils.extensionFromVscodeMarketplace {
          publisher = "microsoft-aspire";
          name = "aspire-vscode";
          version = "1.16.0";
          sha256 = "sha256-au4N/ldulVT0CXC+wOr5pnYrHv36DM9lYdtl/0JWW14=";
        })
        (pkgs.vscode-utils.extensionFromVscodeMarketplace {
          name = "reinhard-dark";
          publisher = "omogwarereinhard";
          version = "0.0.1";
          sha256 = "sha256-clXuSR9GROd/eeoXuvxpuZaSFLtFcVxRjMw4p5dvcY0=";
        })
      ];
    };
  };
}
