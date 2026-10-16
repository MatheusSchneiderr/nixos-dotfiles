{ config, pkgs, lib, ... }:
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

  # After a rebuild links the new theme.json, tell the running panel to re-read it (no-op without a session).
  home.activation.reloadQuickshellTheme = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    $DRY_RUN_CMD env XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}" \
      ${pkgs.quickshell}/bin/quickshell ipc --any-display -c panel call theme reload >/dev/null 2>&1 || true
  '';
}
