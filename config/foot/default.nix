{ config, ... }:
let
  # Same marker trick as tmux/kitty: theme.ini uses base16 "Default Dark" hex as placeholders,
  # swapped for the live Stylix palette. foot.ini stays a live symlink and includes the result.
  raw = builtins.readFile ./theme.ini;
  c = config.lib.stylix.colors;
  font = config.stylix.fonts.monospace.name;
  size = toString config.stylix.fonts.sizes.terminal;
  themed = builtins.replaceStrings
    [ "181818" "282828" "383838" "585858" "b8b8b8" "d8d8d8" "e8e8e8" "f8f8f8" "ab4642" "dc9656" "f7ca88" "a1b56c" "86c1b9" "7cafc2" "ba8baf" "a16946"
      "@opacity@" "@font@" ]
    [ c.base00 c.base01 c.base02 c.base03 c.base04 c.base05 c.base06 c.base07 c.base08 c.base09 c.base0A c.base0B c.base0C c.base0D c.base0E c.base0F
      (toString config.stylix.opacity.terminal) "${font}:size=${size}" ]
    raw;
in
{
  stylix.targets.foot.enable = false;

  xdg.configFile."foot/foot.ini".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/foot/foot.ini";
  xdg.configFile."foot/theme.ini".text = themed;

  programs.plasma.window-rules = [
    {
      description = "Larger initial foot window size";
      match.window-class = {
        value = "foot";
        type = "substring";
      };
      apply.size = {
        value = "1800,1080";
        apply = "initially";
      };
    }
  ];
}
