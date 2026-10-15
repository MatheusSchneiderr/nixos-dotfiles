{ config, pkgs, ... }:
let
  # Same marker trick as kitty/starship: theme.conf uses base16 "Default Dark" hex as
  # placeholder colors, swapped here for the live Stylix palette. tmux.conf stays a live symlink.
  raw = builtins.readFile ./theme.conf;
  c = config.lib.stylix.colors.withHashtag;
  themed = builtins.replaceStrings
    [ "#181818" "#282828" "#383838" "#585858" "#b8b8b8" "#d8d8d8" "#e8e8e8" "#f8f8f8" "#ab4642" "#dc9656" "#f7ca88" "#a1b56c" "#86c1b9" "#7cafc2" "#ba8baf" "#a16946" ]
    [ c.base00    c.base01    c.base02    c.base03    c.base04    c.base05    c.base06    c.base07    c.base08    c.base09    c.base0A    c.base0B    c.base0C    c.base0D    c.base0E    c.base0F  ]
    raw;
in
{
  stylix.targets.tmux.enable = false;

  home.packages = [ pkgs.tmux pkgs.sesh ];

  # plugins auto-install on first launch; later, inside tmux: prefix + I (install) / prefix + U (update)
  xdg.configFile."tmux/tmux.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/tmux/tmux.conf";
  xdg.configFile."tmux/theme.conf".text = themed;

  xdg.configFile."sesh/sesh.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/tmux/sesh.toml";
}
