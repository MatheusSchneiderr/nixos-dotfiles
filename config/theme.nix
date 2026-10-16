{ config }:
let
  c = config.lib.stylix.colors;

  # Takes a file's contents with placeholder colors/fonts and returns it with your real Stylix theme filled in.
  addTheme = fileContents:
    builtins.replaceStrings
      # What to look for: the 16 "Default Dark" placeholder colors, then the UI font (@font@/@size@), terminal font (@mono@/@monosize@) and terminal opacity markers.
      [ "181818" "282828" "383838" "585858" "b8b8b8" "d8d8d8" "e8e8e8" "f8f8f8" "ab4642" "dc9656" "f7ca88" "a1b56c" "86c1b9" "7cafc2" "ba8baf" "a16946" "@font@" "@size@" "@mono@" "@monosize@" "@opacity@" ]
      # What to put instead, in the same order: your theme's colors, fonts and opacity.
      [ c.base00 c.base01 c.base02 c.base03 c.base04 c.base05 c.base06 c.base07 c.base08 c.base09 c.base0A c.base0B c.base0C c.base0D c.base0E c.base0F config.stylix.fonts.sansSerif.name (toString config.stylix.fonts.sizes.desktop) config.stylix.fonts.monospace.name (toString config.stylix.fonts.sizes.terminal) (toString config.stylix.opacity.terminal) ]
      fileContents;
in
addTheme
