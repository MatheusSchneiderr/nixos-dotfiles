# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  backgroundImage = ./assets/dark-pine-forest.jpg;
  # bright, jabuti, onedark-dark, phd, valua, woodland
  base16Theme = "isotope";
  base16SchemePath = "${pkgs.base16-schemes}/share/themes/${base16Theme}.yaml";
  sddmBreezeBackground = pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
    [General]
    background=${backgroundImage}
  '';
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 1;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # This machine has no swap at all otherwise - confirmed during local LLM
  # GPU/NPU concurrency testing that free RAM can bottom out under 300MB
  # under normal (non-pathological) load. zram gives the OOM killer a
  # graceful fallback instead of an outright kill; not meant to be relied on
  # for routine operation, just a safety net.
  zramSwap.enable = true;

  networking.hostName = "laptop-schneider";
  networking.wireless.enable = true; # Enables wireless support via wpa_supplicant.

  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      networkmanager-openvpn
    ];
  };

  programs.bash = {
    completion.enable = true;
    blesh.enable = true;
  };

  # Important for vsCode ssh dev
  programs.nix-ld.enable = true;

  services.xserver.xkb = {
    layout = "br";
    variant = "abnt2";
  };
  console.keyMap = "br-abnt2";

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    konsole
    elisa
    kate
    khelpcenter
  ];

  services.logind.settings.Login.HandlePowerKey = "ignore";

  stylix = {
    enable = true;
    image = backgroundImage;
    base16Scheme = base16SchemePath;
    polarity = "dark";
    fonts = {
      monospace = { package = pkgs.nerd-fonts.jetbrains-mono; name = "JetBrainsMono Nerd Font"; };
      sansSerif = { package = pkgs.noto-fonts; name = "Noto Sans"; };
      sizes.terminal = 13;
      sizes.applications = 11;
      sizes.popups = 11;
    };
    cursor = {
      package = pkgs.whitesur-cursors;
      name = "WhiteSur-cursors";
      size = 24;
    };
  };

  # Battery charge shenanigans (limits at 80% for care) -- Asus-specific,
  # unrelated to the desktop config above.
  systemd.services.asus-battery-charge-limit = {
    description = "Set ASUS battery charge limit to 80%";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c 'echo 80 > /sys/class/power_supply/BAT0/charge_control_end_threshold'";
    };
  };

  # Intel's thermal daemon: keeps the CPU from overshooting into thermal
  # throttling / excess turbo, which indirectly saves power and cuts fan
  # noise. No conflict with power-profiles-daemon (different subsystem).
  services.thermald.enable = true;

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT = "pt_BR.UTF-8";
    LC_MONETARY = "pt_BR.UTF-8";
    LC_NAME = "pt_BR.UTF-8";
    LC_NUMERIC = "pt_BR.UTF-8";
    LC_PAPER = "pt_BR.UTF-8";
    LC_TELEPHONE = "pt_BR.UTF-8";
    LC_TIME = "pt_BR.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = false;

  # Kanata (key remapping / layers) -- Asus-specific hotkey handling,
  # unrelated to the desktop config above.
  services.kanata = {
    enable = true;
    keyboards.notebook = {
      # Scoped to the built-in keyboard only, so the split QMK keyboard is never grabbed.
      # Also grabs the Asus WMI hotkeys device, since the Copilot key (Super_L + F23) is
      # sent through it rather than the main i8042 keyboard.
      devices = [
        "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
        "/dev/input/by-path/platform-asus-nb-wmi-event"
      ];
      config = builtins.readFile ../../config/keyboard/kanata-notebook-keyboard.kbd;
    };
  };

  # Bluetooth
  hardware.bluetooth.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Enable podman (rootless), Docker-API compatible
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # Define a default shell (default is bash but I made explicit)
  users.defaultUserShell = pkgs.bash;
  users.users."schneider" = {
    isNormalUser = true;
    description = "schneider";
    extraGroups = [ "networkmanager" "wheel" "input" ];
  };

  # Vial keyboard configurator
  hardware.keyboard.qmk.enable = true;
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';

  # Lets sshfs mounts be accessed by anyone, not just the mounting user (e.g. local AI models/services).
  programs.fuse.userAllowOther = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # winboat depends on an EOL electron build; allow it until nixpkgs bumps winboat past 0.9.0
  nixpkgs.config.permittedInsecurePackages = [
    "electron-40.10.5"
  ];

  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    usbutils
    pciutils
    sddmBreezeBackground
    base16-schemes # only used at eval time (stylix.base16Scheme) - listed here so GC doesn't reap it
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ "root" ]; # @wheel would cover all sudoers

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  networking.firewall.allowedTCPPorts = [ 8000 ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.05"; # Did you read the comment?
}
