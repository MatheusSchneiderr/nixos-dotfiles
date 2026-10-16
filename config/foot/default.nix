{ config, ... }:
let
  addTheme = import ../theme.nix { inherit config; };
in
{
  stylix.targets.foot.enable = false;

  xdg.configFile."foot/foot.ini".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/foot/foot.ini";
  xdg.configFile."foot/theme.ini".text = addTheme (builtins.readFile ./theme.ini);
}
