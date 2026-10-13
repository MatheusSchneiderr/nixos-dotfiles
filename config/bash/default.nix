{ config, pkgs, ... }:

let
  home = config.home.homeDirectory;
in
{
  imports = [
    ./blesh.nix
    ./starship.nix
  ];

  programs.bash = {
    shellAliases = {
      btw = "echo I use NixOS, btw";
      nixclean = "sudo nix-collect-garbage -d && nix-env --delete-generations old && nix-collect-garbage -d && sudo nix-store --gc && nix-store --optimise";
      # also periodically check `du -sh /var/lib/docker` - orphaned containerd data piles up there even without a docker daemon running; `sudo rm -rf /var/lib/docker` to clear it
      coredump-clean = "sudo rm -fv /var/lib/systemd/coredump/*.zst"; # cleans up systemd crash dumps

      nd = "nix develop";
      mi = "cd ${home}/job";
      cs = "cd ${home}/projects/cfsharp";
      v = "nvim";
      ssh = "kitty +kitten ssh";

      c = "claude";
      # No local-model alias for Claude Code itself (removed) - it always
      # sends a large fixed tool-context payload regardless of backend,
      # which swamps a small/fast local model and isn't worth it even for
      # Qwen. Local models stay reachable through OpenCode and CodeCompanion.

      # llm-ctl: picks and runs one local model at a time (see llm-ctl/).
      llm = "bash ${home}/nixos-dotfiles/llm-ctl/llm-ctl.sh";
      model-stop = "bash ${home}/nixos-dotfiles/llm-ctl/llm-ctl.sh stop";

      ll = "ls -l";
      la = "ls -a";
      g = "git";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gst = "git status";
    };

    initExtra = ''
      reflake() {
        sudo nixos-rebuild switch --flake "${home}/nixos-dotfiles/#laptop-schneider" || return 1

        # ble.sh only sources theme.sh once at shell init, so re-source it
        # in the current shell to pick up any change.
        [[ ''${BLE_VERSION-} ]] && [ -f "$HOME/.config/blesh/themes/theme.sh" ] && source "$HOME/.config/blesh/themes/theme.sh"
      }

      srctheme() {
        ls ${pkgs.base16-schemes}/share/themes/ | grep "$1"
      }

      dc() {
        docker compose -f "''${1:-docker-compose.yml}" up -d
      }
      dcd() {
        docker compose -f "''${1:-docker-compose.yml}" down
      }
      sm() { mkdir -p ~/mnt/"$1" && sshfs "$1:/" ~/mnt/"$1" -o reconnect,ServerAliveInterval=15; }
      smu() { fusermount -u ~/mnt/"$1" && rmdir ~/mnt/"$1"; }

      [[ ''${BLE_VERSION-} ]] && [ -f "$HOME/.config/blesh/themes/theme.sh" ] && source "$HOME/.config/blesh/themes/theme.sh"
    '';
  };

  # Disables broken cargo bash completion that spams errors while typing.
  xdg.dataFile."bash-completion/completions/cargo".text = ''
    _cargo_noop() { COMPREPLY=(); }
    complete -F _cargo_noop cargo
  '';
  xdg.dataFile."bash-completion/completions/cargo.bash".text = ''
    _cargo_noop() { COMPREPLY=(); }
    complete -F _cargo_noop cargo
  '';
}
