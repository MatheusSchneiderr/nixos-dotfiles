{ config, ... }:
let
  addTheme = import ../../theme.nix { inherit config; };
in
{
  xdg.configFile."quickshell/panel".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/desktop/quickshell";
  xdg.configFile."quickshell/theme.json".text = addTheme (builtins.readFile ./theme.json);
}
