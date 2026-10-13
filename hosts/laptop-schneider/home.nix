{ pkgs, ... }:

{
  imports = [
    ../../config/bash
    ../../config/dotnet-tools
    ../../config/kitty
    ../../config/kde
    ../../config/llama-cpp-sycl
    ../../config/nvim
    ../../config/opencode
    ../../config/pi
    ../../config/vscode
  ];

  # blesh, kde, nvim, llama-cpp-sycl, dotnet-tools: no separate enable line -
  # always applied when imported

  programs.bash.enable = true;
  programs.claude-code.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
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
  programs.kitty.enable = true;

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
    filezilla
    obsidian
    libreoffice
    zotero
    vial
    winboat
    zmk-studio

    nodejs
    python3
    gcc
    gnumake
    rustc
    cargo
    clippy
  ];
}
