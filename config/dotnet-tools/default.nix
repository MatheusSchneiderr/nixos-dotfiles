{ config, pkgs, lib, aspire, ... }:

let
  home = config.home.homeDirectory;
  mutableRoot = "${home}/.local/dotnet-10";
  sdk = pkgs.dotnet-sdk_10;

  dotnetLibs = [ pkgs.stdenv.cc.cc.lib pkgs.openssl pkgs.icu ];

  avaloniaLibs = [
    pkgs.fontconfig
    pkgs.freetype
    pkgs.libGL
    pkgs.wayland
    pkgs.libxkbcommon
    pkgs.libx11
    pkgs.libice
    pkgs.libsm
    pkgs.libxext
    pkgs.libxrender
    pkgs.libxrandr
    pkgs.libxi
    pkgs.libxcursor
    pkgs.libxfixes
    pkgs.libxtst
  ];
in
{
  home.packages = [
    sdk
    pkgs.dotnet-ef
    pkgs.azure-cli
    pkgs.openssl
    pkgs.nssTools
    pkgs.icu
    aspire.packages.${pkgs.stdenv.hostPlatform.system}.aspire-cli
  ] ++ avaloniaLibs;

  home.sessionVariables = {
    LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath (dotnetLibs ++ avaloniaLibs)}:$LD_LIBRARY_PATH";
    DOTNET_ROOT = "${mutableRoot}/share/dotnet";
    DOTNET_CLI_HOME = "${home}/.dotnet";
    NUGET_PACKAGES = "${home}/.nuget/packages";
    SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
    DOTNET_ROLL_FORWARD = "LatestMajor";
  };

  home.sessionPath = [
    "${mutableRoot}/bin"
    "${home}/.dotnet/tools"
    "${home}/.local/azd/bin"
  ];

  # The nix store is read-only, but dotnet/NuGet need a writable SDK tree
  # (tool installs, template caches, etc.) - so the SDK gets copied into a
  # mutable root, re-copied only when the store path actually changes.
  home.activation.dotnetSdkMutableRoot = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f "${mutableRoot}/.nix-sdk-store-path" ] || \
       [ "$(cat "${mutableRoot}/.nix-sdk-store-path")" != "${sdk}" ]; then
      run rm -rf "${mutableRoot}"
      run mkdir -p "${mutableRoot}"
      run cp -r ${sdk}/. "${mutableRoot}/"
      run chmod -R u+w "${mutableRoot}"
      $DRY_RUN_CMD bash -c 'echo "${sdk}" > "${mutableRoot}/.nix-sdk-store-path"'
    fi
  '';

  home.activation.avaloniaTemplates = lib.hm.dag.entryAfter [ "dotnetSdkMutableRoot" ] ''
    export DOTNET_ROOT="${mutableRoot}/share/dotnet"
    export PATH="${mutableRoot}/bin:$PATH"
    export NUGET_PACKAGES="${home}/.nuget/packages"
    if ! "${mutableRoot}/bin/dotnet" new list 2>/dev/null | grep -q avalonia; then
      $DRY_RUN_CMD "${mutableRoot}/bin/dotnet" new install Avalonia.Templates
    fi
  '';

  home.activation.azdInstall = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -x "${home}/.local/azd/bin/azd" ]; then
      run mkdir -p "${home}/.local/azd/bin"
      $DRY_RUN_CMD bash -c 'curl -fsSL https://aka.ms/install-azd.sh | bash -s -- --install-folder "${home}/.local/azd/bin" --symlink-folder "${home}/.local/azd/bin"'
    fi
  '';
}
