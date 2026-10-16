{ pkgs, ... }:

let
  # nixpkgs dropped Firefox 140 ESR (nixpkgs#567873, 2026-09-28), which broke
  # zotero's build (nixpkgs#568692; fix open, unmerged: nixpkgs#569006).
  # Pin zotero to the last nixpkgs rev before that drop until the fix lands.
  zotero-pinned = (import (builtins.fetchTarball {
    url = "https://releases.nixos.org/nixpkgs/nixpkgs-26.11pre1063758.e8be7818e19a/nixexprs.tar.xz";
    sha256 = "sha256-qeiZaY+0tpZXliRA9odCNx+sOfIOhnkcUq9t+ctPrRA=";
  }) {
    system = pkgs.stdenv.hostPlatform.system;
    config.allowUnfree = true;
  }).zotero;
in
{
  imports = [
    ../../config/bash
    ../../config/desktop
    ../../config/dotnet-tools
    ../../config/foot
    ../../config/llama-cpp-sycl
    ../../config/nvim
    ../../config/opencode
    ../../config/pi
    ../../config/tmux
    ../../config/vscode
  ];

  # blesh, nvim, llama-cpp-sycl, dotnet-tools: no separate enable line -
  # always applied when imported

  programs.bash.enable = true;
  programs.claude-code.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.foot.enable = true;
  programs.gh = {
    enable = true;
    settings.git_protocol = "https";
    gitCredentialHelper.enable = true;
  };
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Matheus Schneider";
        email = "matheusschneidermartins@gmail.com";
      };
      credential.helper = "store";
    };
  };

  programs.opencode.enable = true;
  programs.pi-coding-agent.enable = true;
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [ "~/.ssh/hosts" ];
    settings = {
      "*" = {
        ControlMaster = "auto";
        ControlPath = "~/.ssh/control-%h-%p-%r";
        ControlPersist = "10m";
      };
    };
  };
  programs.starship.enable = true;
  programs.vscode.enable = true;

  home.username = "schneider";
  home.homeDirectory = "/home/schneider";
  home.stateVersion = "26.05";

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.packages = with pkgs; [
    sshfs
    firefox
    google-chrome
    dbeaver-bin
    bruno
    wl-clipboard
    tigervnc
    gh
    lazygit
    filezilla
    obsidian
    libreoffice
    zotero-pinned
    vial
    winboat
    zmk-studio
    loupe
    celluloid

    nodejs
    python3
    gcc
    gnumake
    rustc
    cargo
    clippy
  ];
}
