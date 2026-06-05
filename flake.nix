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

        buildInputs = [
          pkgs.wayland
          pkgs.wayland-scanner
          pkgs.wayland-protocols
          pkgs.libxkbcommon
        ];
        # Source : https://zigtools.org/zls/guides/packaging/
        #├── build.zig
        #├── build.zig.zon
        #├── LICENSE
        #├── README.md
        #├── src
        #└── zig-pkg
        #    ├── diffz-0.0.1-G2tlIYrNAQAQx3cuIp7EVs0xvxbv9DCPf4YuHmvubsrZ
        # NOTE: Zig 0.16 requires this specific local directory to scan for dependencies.
        #     # Since Nix disables internet access during builds, we will manually create
        #     # this `zig-pkg` folder and link our `kwm_deps` inside the `preBuild` phase.
        kwm_deps = pkgs.callPackage ./deps.nix { };
        preBuild = ''
          mkdir -p zig-pkg
          cp -r ${kwm_deps}/* zig-pkg
        '';
        buildPhase = ''
          runHook preBuild
          zig build --release=fast
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
