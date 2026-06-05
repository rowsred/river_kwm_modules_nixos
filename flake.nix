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
      pkgs = import nixpkgs { inherit system; };

      kwm = pkgs.stdenv.mkDerivation rec {
        pname = "kwm";
        version = "0.3.0";

        src = pkgs.fetchFromGitHub {
          owner = "kewuaa";
          repo = "kwm";
          rev = "v${version}";
          sha256 = "sha256-hX76wTHPTgg5RAHILfd3CjRKPlgAwGSK3lG82IFoUUs=";
        };
        nativeBuildInputs = [
          pkgs.zig_0_16
          pkgs.pkg-config
          pkgs.pixman
          pkgs.fcft
        ];
        kwm_deps = pkgs.callPackage ./deps.nix { };

        buildInputs = [
          pkgs.wayland
          pkgs.wayland-scanner
          pkgs.wayland-protocols
          pkgs.libxkbcommon
        ];
        buildPhase = ''
          zig build --release=fast --system ${kwm_deps}
        '';

        installPhase = ''
                    runHook preInstall
                    
                    mkdir -p $out/bin
                    cp zig-out/bin/kwm $out/bin/

                    mkdir -p $out/share/kwm
                    cp config.zon $out/share/kwm/

                    mkdir -p $out/share/wayland-sessions
                    cat > $out/share/wayland-sessions/river-kwm.desktop <<EOF
          [Desktop Entry]
          Name=River (kwm)
          Comment=River Wayland compositor with kwm
          Exec=${pkgs.river}/bin/river -c $out/bin/kwm
          Type=Application
          DesktopNames=river
          EOF

                    runHook postInstall
        '';

        passthru.providedSessions = [ "river-kwm" ];
      };
    in
    {
      packages.${system}.default = kwm;

      homeModules.default =
        { ... }:
        {
          home.packages = [
            kwm
            pkgs.river
            pkgs.foot
            pkgs.wl-clipboard-rs
            pkgs.wmenu
          ];
        };

      nixosModules.default =
        { ... }:
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
