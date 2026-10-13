{ pkgs, ... }:
let
  # nixpkgs' llama-cpp has no SYCL variant; builds GGML_SYCL=ON with Intel's icx/icpx.
  llama-cpp-sycl = pkgs.llama-cpp.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.intel-oneapi-toolkit ];
    buildInputs = (old.buildInputs or [ ]) ++ [
      pkgs.level-zero
      pkgs.ocl-icd
      pkgs.opencl-headers
      pkgs.opencl-clhpp
    ];
    # icx/icpx bypass Nix's cc-wrapper, so toolchain/include/lib flags are hand-wired below.
    cmakeFlags =
      let
        includeFlags = "-idirafter ${pkgs.glibc.dev}/include -I${pkgs.level-zero}/include -I${pkgs.opencl-headers}/include -I${pkgs.opencl-clhpp}/include";
        libDirs = [
          "${pkgs.stdenv.cc.cc.lib}/lib"
          "${pkgs.level-zero}/lib"
          "${pkgs.ocl-icd}/lib"
          "${pkgs.openssl.out}/lib"
        ];
        linkFlags = (pkgs.lib.concatMapStringsSep " " (d: "-L${d}") libDirs)
          + " -Wl,-rpath,${pkgs.lib.makeLibraryPath libDirs}";
        toolchainFlags = "--gcc-toolchain=${pkgs.stdenv.cc.cc} --sysroot=${pkgs.glibc} ${includeFlags} ${linkFlags}";
      in
      (builtins.filter
        (f: !(pkgs.lib.hasInfix "GGML_VULKAN" f) && !(pkgs.lib.hasInfix "CMAKE_CXX_COMPILER" f) && !(pkgs.lib.hasInfix "CMAKE_C_COMPILER" f))
        old.cmakeFlags
      ) ++ [
        (pkgs.lib.cmakeBool "GGML_SYCL" true)
        (pkgs.lib.cmakeFeature "GGML_SYCL_TARGET" "INTEL")
        # GGML_SYCL_F16 benchmarked and rejected (slower end-to-end); don't re-enable without re-testing.
        (pkgs.lib.cmakeFeature "CMAKE_C_COMPILER" "${pkgs.intel-oneapi-toolkit}/2026.0/bin/icx")
        (pkgs.lib.cmakeFeature "CMAKE_CXX_COMPILER" "${pkgs.intel-oneapi-toolkit}/2026.0/bin/icpx")
        (pkgs.lib.cmakeFeature "CMAKE_C_FLAGS" toolchainFlags)
        (pkgs.lib.cmakeFeature "CMAKE_CXX_FLAGS" toolchainFlags)
        (pkgs.lib.cmakeFeature "CMAKE_EXE_LINKER_FLAGS" toolchainFlags)
        (pkgs.lib.cmakeFeature "CMAKE_SHARED_LINKER_FLAGS" toolchainFlags)
      ];
  });

  # symlinkJoin, not overrideAttrs, so wrapper-only env tweaks skip a full SYCL rebuild.
  llama-cpp-sycl-wrapped = pkgs.symlinkJoin {
    name = "llama-cpp-sycl-wrapped";
    paths = [ llama-cpp-sycl ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/llama-server \
        --set OCL_ICD_VENDORS ${pkgs.intel-compute-runtime}/etc/OpenCL/vendors \
        --set LD_LIBRARY_PATH ${pkgs.intel-oneapi-toolkit}/2026.0/lib:${pkgs.intel-oneapi-toolkit}/lib:${pkgs.lib.makeLibraryPath [ pkgs.level-zero pkgs.intel-gmmlib ]}
    '';
  };
in
{
  home.packages = [ llama-cpp-sycl-wrapped ];
}
