{ config, ... }:
let
  addTheme = import ../theme.nix { inherit config; };
in
{
  xdg.configFile."blesh/themes/theme.sh".text = addTheme (builtins.readFile ./blesh-theme.sh);
}
