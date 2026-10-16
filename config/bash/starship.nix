{ config, ... }:
let
  addTheme = import ../theme.nix { inherit config; };
in
{
  stylix.targets.starship.enable = false;

  xdg.configFile."starship.toml".text = addTheme (builtins.readFile ./starship.toml);
}
