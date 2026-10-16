{ config, pkgs, ... }:
let
  addTheme = import ../theme.nix { inherit config; };
  lock = "${pkgs.quickshell}/bin/quickshell -c panel ipc call lock lock";
in
{
  imports = [
    ./compositor
    ./quickshell
  ];

  services.cliphist.enable = true;
  services.polkit-gnome.enable = true;

  services.swayidle = {
    enable = true;
    timeouts = [
      { timeout = 300; command = lock; }
      { timeout = 600; command = "${pkgs.systemd}/bin/systemctl suspend"; }
    ];
    events = {
      before-sleep = lock;
    };
  };

  systemd.user.services.swaybg = {
    Unit = {
      Description = "Wallpaper";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.swaybg}/bin/swaybg -i ${config.stylix.image} -m fill";
      Restart = "on-failure";
      RestartSec = 1;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  xdg.configFile."zathura/zathurarc".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/desktop/zathurarc";
  xdg.configFile."zathura/theme".text =
    addTheme (builtins.readFile ./zathura-theme);

  home.packages = with pkgs; [
    quickshell
    (lua5_4.withPackages (ps: [ ps.luasocket ps.cjson ]))
    papirus-icon-theme
    zathura
    thunar
    brightnessctl
    networkmanagerapplet
    grim
    slurp
    swappy
    wlr-randr
    pulseaudio
  ];
}
