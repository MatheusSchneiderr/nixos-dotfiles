{ config, pkgs, ... }:
let
  addTheme = import ../theme.nix { inherit config; };
in
{
  stylix.targets.tmux.enable = false;

  home.packages = [ pkgs.tmux pkgs.sesh ];

  # plugins auto-install on first launch; later, inside tmux: prefix + I (install) / prefix + U (update)
  xdg.configFile."tmux/tmux.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/tmux/tmux.conf";
  xdg.configFile."tmux/theme.conf".text = addTheme (builtins.readFile ./theme.conf);

  xdg.configFile."sesh/sesh.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/tmux/sesh.toml";
}
