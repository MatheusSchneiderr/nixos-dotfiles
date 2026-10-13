{ config, ... }:
{
  # points at the same llm-ctl backend used from Neovim; opencode doesn't auto-discover models.
  # All llm-ctl tiers share port 8901; check llm-ctl to see which is active.
  # No-think params live server-side in models.ini (differs per model, client can't tell which is loaded).
  xdg.configFile."opencode/opencode.json".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/opencode/opencode.json";
}
