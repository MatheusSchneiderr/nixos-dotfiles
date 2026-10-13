{ config, ... }:
let
  # Stylix's own kitty target would normally inject `include <store-path>` into
  # kitty.conf for theming (see stylix.targets.kitty.enable below), which keeps
  # kitty.conf itself from being a real, directly-readable file. Disable that
  # target and do the same marker-color substitution trick starship/blesh use
  # instead: kitty.conf is a plain, hand-edited file using base16 "Default Dark"
  # as placeholder colors, swapped here for the live Stylix base16 scheme.
  raw = builtins.readFile ./kitty.conf;
  c = config.lib.stylix.colors.withHashtag;
  themed = builtins.replaceStrings
    [ "#181818" "#282828" "#383838" "#585858" "#b8b8b8" "#d8d8d8" "#e8e8e8" "#f8f8f8" "#ab4642" "#dc9656" "#f7ca88" "#a1b56c" "#86c1b9" "#7cafc2" "#ba8baf" "#a16946" ]
    [ c.base00    c.base01    c.base02    c.base03    c.base04    c.base05    c.base06    c.base07    c.base08    c.base09    c.base0A    c.base0B    c.base0C    c.base0D    c.base0E    c.base0F  ]
    raw;
in
{
  stylix.targets.kitty.enable = false;

  programs.kitty = {
    # font/shell-integration stay as structured options - font needs Nix to
    # install the font package, shell integration needs to wire bash's initExtra.
    font = {
      inherit (config.stylix.fonts.monospace) package name;
      size = config.stylix.fonts.sizes.terminal;
    };
    settings.background_opacity = toString config.stylix.opacity.terminal;

    # Shell integration switches the cursor to a thin beam at the shell
    # prompt by default - keep it block everywhere instead.
    shellIntegration.mode = "no-cursor";

    extraConfig = themed;
  };

  programs.plasma.window-rules = [
    {
      description = "Larger initial kitty window size";
      match.window-class = {
        value = "kitty";
        type = "substring";
      };
      apply.size = {
        value = "1800,1080";
        apply = "initially";
      };
    }
  ];
}
