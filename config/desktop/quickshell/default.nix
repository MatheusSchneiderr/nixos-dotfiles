{ config, pkgs, ... }:
let
  addTheme = import ../../theme.nix { inherit config; };
  home = config.home.homeDirectory;
in
{
  xdg.configFile."quickshell/panel".source =
    config.lib.file.mkOutOfStoreSymlink "${home}/nixos-dotfiles/config/desktop/quickshell";
  xdg.configFile."quickshell/theme.json".text = addTheme (builtins.readFile ./theme.json);

  # Screen-share picker: the portal asks our Quickshell picker (modules/screencast) which screen to share.
  # The drop-in sorts after NixOS's overrides.conf, so its ExecStart replaces the one with the NixOS-generated --config.
  xdg.configFile."xdg-desktop-portal-wlr/config".text = ''
    [screencast]
    chooser_type=dmenu
    chooser_cmd=${home}/.config/quickshell/panel/modules/screencast/portal-pick
  '';
  xdg.configFile."systemd/user/xdg-desktop-portal-wlr.service.d/quickshell-picker.conf".text = ''
    [Service]
    ExecStart=
    ExecStart=${pkgs.xdg-desktop-portal-wlr}/libexec/xdg-desktop-portal-wlr --config=%h/.config/xdg-desktop-portal-wlr/config
  '';
}
