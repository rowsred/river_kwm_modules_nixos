{
  description = "kwm modules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
      owner = "kewuaa";
      kwim_version = "0.2.0";
      kwm_version = "0.3.0";
      kwm_deps = pkgs.callPackage ./kwm_deps.nix { };
      kwim_deps = pkgs.callPackage ./kwim_deps.nix { };
      sharedNativeBuildInputs = builtins.attrValues {
          inherit (pkgs)
            zig_0_16
            pkg-config
            pixman
            fcft
          ;
        };
      sharedBuildInputs = builtins.attrValues {
          inherit (pkgs)
            wayland
            wayland-scanner
            wayland-protocols
            libxkbcommon
          ;
        };
      kwim = pkgs.stdenv.mkDerivation {
        pname = "kwim";
        version = kwim_version;
        src = pkgs.fetchFromGitHub {
          inherit owner;
          repo = "kwim";
          rev = "v${kwim_version}";
          sha256 = "sha256-ewg259zRCMGq75XXMmPqoFwD5NBEFXXsIj1rvMy31uw=";
        };
        buildInputs = sharedBuildInputs;
        nativeBuildInputs = sharedNativeBuildInputs;
        deps = kwim_deps;
        zigBuildFlags = [ "--system" kwim_deps ];
      };
      kwm = pkgs.stdenv.mkDerivation {
        pname = "kwm";
        version = kwm_version;

        src = pkgs.fetchFromGitHub {
          owner = "kewuaa";
          repo = "kwm";
          rev = "v${kwm_version}";
          sha256 = "sha256-hX76wTHPTgg5RAHILfd3CjRKPlgAwGSK3lG82IFoUUs=";
        };

        deps = pkgs.callPackage ./kwm_deps.nix { };
        zigBuildFlags = [ "--system" kwm_deps ];

        nativeBuildInputs = sharedNativeBuildInputs;

        buildInputs = sharedBuildInputs ++ [
          kwim
        ];

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
      devShell.${system} = pkgs.mkShell {
        packages = builtins.attrValues {
          inherit (pkgs) zon2nix;
        };
      };
      packages.${system} = {
        inherit kwm kwim;
        default = kwm;
      };
      homeModules.default =
        { pkgs, ... }:
        {
          home.packages = builtins.attrValues {
            inherit kwm kwim;
            inherit (pkgs)
              foot
              wl-clipboard-rs
              wmenu
            ;
          };
        };
      nixosModules.default =
        { config, ... }:
        {
          services.displayManager.sessionPackages = [ kwm ];
          environment.systemPackages = builtins.attrValues {
            inherit kwm kwim;
            inherit (pkgs)
              foot
              wl-clipboard-rs
              wmenu
            ;
          };
        };

    };
}
