{ config, pkgs, ... }:
{
  # `pi install npm:...` shells out to npm, not on the wrapped pi binary's PATH otherwise
  programs.pi-coding-agent.extraPackages = [ pkgs.nodejs ];

  # mirrors config/opencode's local-gpu provider. All llm-ctl tiers share port 8901;
  # check llm-ctl to see which one is actually running.
  # settings.json: packages pinned to pi-agent-suite@2.11.2 - the last version before
  # buildSessionProjection was added (2.12.0+ requires pi-coding-agent >=0.87.0; ours is
  # pinned at 0.84.3).
  # models.json: reasoning=true + thinkingFormat=chat-template with explicit
  # chatTemplateKwargs (not qwen-chat-template, which only ever sends enable_thinking as a
  # bare bool and drops the actual effort level) enables /thinking. contextWindow kept in
  # sync with models.ini's ctx-size (currently 65536 via [*]).
  home.file.".pi/agent/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/pi/settings.json";
  home.file.".pi/agent/models.json".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nixos-dotfiles/config/pi/models.json";

  home.file.".pi/agent/agent-suite/context-projection/config.json".text = builtins.toJSON {
    enabled = true;
  };
}
