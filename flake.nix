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
          rev = "v0.2.1";
          sha256 = "sha256-N/K+AcDC1TnlhZqjyFf/HlYt0s9lP7JaA00losVnops=";
        };

        deps = pkgs.callPackage ./deps.nix { };

        zigBuildFlags = [
          "--system"
          "${deps}"
        ];

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
          export HOME=$TMPDIR
          export ZIG_GLOBAL_CACHE_DIR=$TMPDIR/zig-cache
          mkdir -p $ZIG_GLOBAL_CACHE_DIR

          cp -r ${deps}/* $ZIG_GLOBAL_CACHE_DIR/
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
