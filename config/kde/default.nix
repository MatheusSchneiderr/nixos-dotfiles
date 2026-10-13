{
  programs.plasma.enable = true;

  programs.plasma.kwin.virtualDesktops = {
    number = 4;
    rows = 2;
  };

  # Lag reduction on Intel iGPU: disable expensive compositor effects/animations and Baloo indexing.
  programs.plasma.kwin.effects = {
    blur.enable = false;
    wobblyWindows.enable = false;
    cube.enable = false;
    translucency.enable = false;
    fallApart.enable = false;
    dimInactive.enable = false;
    slideBack.enable = false;
    windowOpenClose.animation = "off";
    desktopSwitching.animation = "off";
    minimization.animation = "off";
  };

  programs.plasma.configFile."kwinrc"."Compositing" = {
    Enabled = true;
    Backend = "OpenGL";
    WindowsBlockCompositing = false;
  };

  programs.plasma.configFile."baloofilerc"."Basic Settings"."Indexing-Enabled" = false;

  programs.plasma.shortcuts.kwin = {
    "Window Close" = "Meta+Q";
    "Window Maximize" = [ "Meta+M" "F11" ];

    "Switch Window Up" = "Meta+K";
    "Switch Window Down" = "Meta+J";
    "Switch Window Left" = "Meta+H";
    "Switch Window Right" = "Meta+L";

    "Switch One Desktop to the Left" = "Meta+Alt+H";
    "Switch One Desktop to the Right" = "Meta+Alt+L";
    "Switch One Desktop Up" = "Meta+Alt+K";
    "Switch One Desktop Down" = "Meta+Alt+J";
  };

  programs.plasma.shortcuts."ksmserver" = {
    "Lock Session" = "Meta+Alt+Esc";
  };
  programs.plasma.shortcuts."plasmashell" = {
    "manage activities" = "Meta+Ctrl+Q";
  };
}
