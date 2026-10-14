{ config, pkgs, ... }:
let
  dotfiles = "${config.home.homeDirectory}/nixos-dotfiles/config/tmux";
in
{
  # tmux.conf is self-managed (TPM plugins, hardcoded theme), so Stylix stays out of it
  stylix.targets.tmux.enable = false;

  home.packages = [ pkgs.tmux pkgs.sesh ];

  # plugins auto-install on first launch; later, inside tmux: prefix + I (install) / prefix + U (update)
  xdg.configFile."tmux/tmux.conf".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/tmux.conf";
  xdg.configFile."sesh/sesh.toml".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/sesh.toml";
}
