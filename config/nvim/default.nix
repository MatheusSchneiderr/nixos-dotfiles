{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    neovim
    ripgrep
    fd
    unzip
    fzf
    tree-sitter
  ];

  xdg.configFile."nvim/init.lua".source =
    config.lib.file.mkOutOfStoreSymlink "/home/schneider/nixos-dotfiles/config/nvim/init.lua";

  xdg.configFile."nvim/lazy-lock.json".source =
    config.lib.file.mkOutOfStoreSymlink "/home/schneider/nixos-dotfiles/config/nvim/lazy-lock.json";

  xdg.configFile."nvim/lua".source =
    config.lib.file.mkOutOfStoreSymlink "/home/schneider/nixos-dotfiles/config/nvim/lua";
}
