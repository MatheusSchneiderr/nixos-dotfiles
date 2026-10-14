{ pkgs, ... }:

{
  programs.tmux = {
    mouse = true;
    escapeTime = 0;
    historyLimit = 50000;
    baseIndex = 1;
    terminal = "tmux-256color";
    plugins = with pkgs.tmuxPlugins; [
      {
        plugin = tmux-which-key;
        extraConfig = "set -g @tmux-which-key-xdg-enable 1";
      }
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-processes 'claude opencode lazygit'
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = continuum;
        extraConfig = "set -g @continuum-restore 'on'";
      }
    ];
    extraConfig = ''
      set -as terminal-features ",*:RGB"
      set -s extended-keys on
      set -as terminal-features ",foot*:extkeys"
      bind -n C-BSpace send-keys C-w
      bind -n C-h send-keys C-w
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
    '';
  };
}
