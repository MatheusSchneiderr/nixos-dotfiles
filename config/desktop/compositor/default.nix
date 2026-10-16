{ config, ... }:
let
  repo = "${config.home.homeDirectory}/nixos-dotfiles/config/desktop/compositor";
  addTheme = import ../../theme.nix { inherit config; };
in
{
  systemd.user.targets.wayfire-session = {
    Unit = {
      Description = "Wayfire session";
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      After = [ "graphical-session-pre.target" ];
    };
  };

  xdg.configFile."wayfire/edge-focus.lua".source = config.lib.file.mkOutOfStoreSymlink "${repo}/edge-focus.lua";
  xdg.configFile."wayfire/workspace-watch.lua".source = config.lib.file.mkOutOfStoreSymlink "${repo}/workspace-watch.lua";
  xdg.configFile."wayfire/window.lua".source = config.lib.file.mkOutOfStoreSymlink "${repo}/window.lua";
  xdg.configFile."wayfire/wfipc.lua".source = config.lib.file.mkOutOfStoreSymlink "${repo}/wfipc.lua";

  xdg.configFile."wayfire.ini".text =
    builtins.replaceStrings [ "@home@" ] [ config.home.homeDirectory ] (addTheme (builtins.readFile ./wayfire.ini));
}
