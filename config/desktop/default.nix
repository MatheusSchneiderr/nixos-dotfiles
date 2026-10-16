{ config, pkgs, ... }:
let
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

  home.packages = with pkgs; [
    quickshell
    (lua5_4.withPackages (ps: [ ps.luasocket ps.cjson ]))
    papirus-icon-theme
    thunar
    tumbler
    brightnessctl
    networkmanagerapplet
    grim
    slurp
    swappy
    wlr-randr
    pulseaudio
  ];
}
