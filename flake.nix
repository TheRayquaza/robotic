{
  description = "Simple python FHS devshell (Intel GPU only)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        python = pkgs.python312;
        hostKernelHeaders = pkgs.linuxHeaders;
      in {
        devShells.default =
          (pkgs.buildFHSEnv {
            name = "python-fhs";

            targetPkgs = _: [
              python
              pkgs.uv
              pkgs.zlib
              pkgs.conda
              pkgs.ffmpeg_7-full

              # Intel GPU (Mesa)
              pkgs.mesa
              pkgs.libglvnd
              pkgs.libva

              # X11
              pkgs.xorg.libX11
              pkgs.xorg.libXext
              pkgs.xorg.libxcb
              pkgs.xorg.libXrender
              pkgs.xorg.libXrandr
              pkgs.xorg.libXi
              pkgs.xorg.libXfixes
              pkgs.xorg.libXcursor
              pkgs.xorg.libXinerama
              pkgs.xorg.xcbutil
              pkgs.xorg.xcbutilimage
              pkgs.xorg.xcbutilkeysyms
              pkgs.xorg.xcbutilwm
              pkgs.xorg.xcbutilrenderutil
              pkgs.libxkbcommon

              # GTK, Qt
              pkgs.gtk3
              pkgs.glib
              pkgs.qt5.qtbase

              hostKernelHeaders
            ];

            extraMounts = [{
              source = "/run/opengl-driver";
              target = "/run/opengl-driver";
              recursive = true;
            }];

            profile = ''
              export CFLAGS="-I${hostKernelHeaders}/include"
              export CPPFLAGS="$CFLAGS"
              export UV_PYTHON=${python}

              # Intel Mesa (no NVIDIA)
              export LIBGL_DRIVERS_PATH=/run/opengl-driver/lib/dri
              export LD_LIBRARY_PATH=${pkgs.ffmpeg}/lib:$LD_LIBRARY_PATH
              export LD_LIBRARY_PATH=/run/opengl-driver/lib:$LD_LIBRARY_PATH
              export __EGL_VENDOR_LIBRARY_DIRS=/run/opengl-driver/share/glvnd/egl_vendor.d

              bash
            '';
          }).env;
      });
}
