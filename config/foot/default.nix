{ ... }:

{
  programs.foot.settings.main.shell = "tmux new -A -s main";

  programs.plasma.window-rules = [
    {
      description = "Larger initial foot window size";
      match.window-class = {
        value = "foot";
        type = "substring";
      };
      apply.size = {
        value = "1800,1080";
        apply = "initially";
      };
    }
  ];
}
