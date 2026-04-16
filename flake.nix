{
  description = "kwm modules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;

      };

      kwm = pkgs.stdenv.mkDerivation rec {
        pname = "kwm";
        version = "git";

        src = pkgs.fetchFromGitHub {
          owner = "kewuaa";
          repo = "kwm";
          rev = "v0.2.2";
          sha256 = "sha256-Vfdi9AXf3497JAVrdMcheQcDFnqgSrXQy92+pU02c/Q=";
        };
        #dependencies
        xkbcommon = pkgs.fetchzip {
          url = "https://codeberg.org/ifreund/zig-xkbcommon/archive/v0.3.0.tar.gz";
          sha256 = "sha256-e5bPEfxl4SQf0cqccLt/py1KOW1+Q1+kWZUEXBbh9oQ=";
        };
        wayland = pkgs.fetchzip {
          url = "https://codeberg.org/ifreund/zig-wayland/archive/v0.5.0.tar.gz";
          sha256 = "sha256-mhqOtC26iACIvQUq74AbLSXSPsnWMi3AvDV7G2uElpo=";
        };
        mvzr = pkgs.fetchzip {
          url = "https://github.com/mnemnion/mvzr/archive/refs/tags/v0.3.8.tar.gz";
          sha256 = "sha256-weWDvirm7PndEoiDRK62NE4CJS6BiXca5/XVpppzWUA=";
        };
        fcft = pkgs.fetchzip {
          url = "https://git.sr.ht/~novakane/zig-fcft/archive/v2.0.0.tar.gz";
          sha256 = "sha256-qDEtiZNSkzN8jUSnZP/itqh8rMf+lakJy4xMB0I8sxQ=";
        };
        pixman = pkgs.fetchzip {
          url = "https://codeberg.org/ifreund/zig-pixman/archive/v0.3.0.tar.gz";
          sha256 = "sha256-8tA4auo5FEI4IPnomV6bkpQHUe302tQtorFQZ1l14NU=";
        };
        kwim = pkgs.fetchzip {
          url = "https://github.com/kewuaa/kwim/archive/refs/tags/v0.1.4.tar.gz";
          sha256 = "sha256-YTcIzE3rpBc3v70/Y5YKo+bc2DfOkF8LzawSst/QJjA=";
        };

        nativeBuildInputs = [
          pkgs.zig
          pkgs.pkg-config
          pkgs.pixman
          pkgs.fcft
        ];

        buildInputs = [
          pkgs.wayland
          pkgs.wayland-scanner
          pkgs.wayland-protocols
          pkgs.libxkbcommon
        ];

        preBuild = ''
          rm -rf $TMPDIR/zig-cache
          export ZIG_GLOBAL_CACHE_DIR=$TMPDIR/zig-cache
          mkdir -p $ZIG_GLOBAL_CACHE_DIR/p
            ln -s ${xkbcommon} $ZIG_GLOBAL_CACHE_DIR/p/
            ln -s ${wayland}/ $ZIG_GLOBAL_CACHE_DIR/p/
            ln -s ${mvzr} $ZIG_GLOBAL_CACHE_DIR/p/
            ln -s ${fcft} $ZIG_GLOBAL_CACHE_DIR/p/
            ln -s ${kwim} $ZIG_GLOBAL_CACHE_DIR/p/
        '';
        installPhase = ''
          mkdir -p $out/bin
          cp zig-out/bin/kwm $out/bin/

          mkdir -p $out/share/kwm
          cp config.zon $out/share/kwm/

          mkdir -p $out/share/wayland-sessions
          cat > $out/share/wayland-sessions/river-kwm.desktop <<EOF
            [Desktop Entry]
            Name=River (kwm)
            Comment=River Wayland compositor with kwm
            Exec=${pkgs.river}/bin/river -c ${placeholder "out"}/bin/kwm
            Type=Application
            DesktopNames=river
            EOF
        '';
        passthru.providedSessions = [ "river-kwm" ];

      };
    in
    {
      packages.${system}.default = kwm;
      nixosModules.default =
        { config, ... }:
        {
          services.displayManager.sessionPackages = [ kwm ];
          environment.systemPackages = [
            kwm
            pkgs.foot
            pkgs.wl-clipboard-rs
            pkgs.wmenu
            pkgs.river
          ];

        };
    };

}
