# Bracketed starship prompt, themed with the active Stylix base16 palette.
# starship.toml is the readable source of truth (edit symbols/layout/
# structure there directly), but its color hex values are Stylix "markers" --
# builtins.replaceStrings swaps each one for the live base16 color at build
# time, so the prompt re-themes automatically when the Stylix scheme changes.
# Pure Nix (matches how blesh/kitty interpolate Stylix colors in this repo)
# -- no perl, no runCommand, no extra derivation.
{ config, ... }:
let
  c = config.lib.stylix.colors.withHashtag;
  raw = builtins.readFile ./starship.toml;
  themed = builtins.replaceStrings
    [ "#83a598" "#d3869b" "#8ec07c" "#fabd2f" "#fb4934" "#b8bb26" "#5a524c" ]
    [ c.base0D    c.base0E    c.base0C    c.base0A    c.base08    c.base0B    c.base03 ]
    raw;
in
{
  # We hand-manage the full themed toml below; stop Stylix's own starship
  # target from also theming it, so the two don't fight over the same file.
  stylix.targets.starship.enable = false;

  xdg.configFile."starship.toml".text = themed;
}
