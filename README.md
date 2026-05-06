# River KWM NixOS Module V.0.2.2

This repository provides a Nix module for NixOS and Home Manager to easily install the **River** Wayland compositor integrated with **kwm**, a custom **Zig-based window manager**. This project automates the build process, environment setup, and session integration.



# Official repo kwm
[https://github.com/kewuaa/kwm]

## ✨ Features

*   **Native Zig Build**: Compiles `kwm` from source using Nix's sandboxed build environment.
*   **Plug-and-Play Session**: Automatically generates a `river-kwm.desktop` session entry for GDM, SDDM, or Ly.
*   **Curated Environment**: Bundles essential Wayland tools (`foot`, `wmenu`, `wl-clipboard`) out of the box.
*   **Modular Architecture**: Easily integrable into any NixOS flake-based configuration.

---

## 📊 Platform Support & Recommendation

| Platform     | Recommended Module | Note                                                                 |
|--------------|-------------------|----------------------------------------------------------------------|
| NixOS        | NixOS Module      | ⭐ **Highly Recommended**. Handles SDDM integration and system environment variables automatically. |
| Non-NixOS    | Home Manager      | ⚠️ Only tested on **Void Linux**. Manual steps (e.g. copying `.desktop`) are required for full integration. 


### 1. NixOS Module (Highly Recommended) `flake.nix`

Add the repository to your inputs:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # Add river-kwm-module
    river-kwm.url = "github:rowsred/river_kwm_modules_nixos";
  };

  outputs = { self, nixpkgs, river-kwm, ... }: {
    nixosConfigurations.YOUR_HOSTNAME = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        
        # Include the module
        river-kwm.nixosModules.default
      ];
    };
  };
}

```
### 2. home-manager or Non-NixOS `flake.nix`

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # 2. Add river-kwm-module
    river-kwm.url = "github:rowsred/river_kwm_modules_nixos";
  };

  outputs = { self, nixpkgs, home-manager, river-kwm, ... }: {
    homeConfigurations."YOUR_USERNAME" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      
      modules = [
        ./home.nix
        # 3. Include the Home Manager module
        river-kwm.homeModules.default
      ];
    };
  };
}
```
# ⚠️ Important for home-manager or Non-NixOS users : Post-Build Notes
If you are using this module on a non-NixOS system, please follow these critical steps after a successful rebuild:

# 1. Manual Launch (TTY)
After rebuilding, you can start the session directly from the **TTY** by logging into your user and running:
```bash
river -c kwm
```
# 2. Why TTY? (Display Manager Notice)
The Home Manager module generates a .desktop file in the user profile. However, most Display Managers (like SDDM) do not scan user-level directories.
To use a Display Manager:
You must manually copy the session file to the system directory so the DM can "see" it:
```bash
sudo cp ~/.nix-profile/share/wayland-sessions/*.desktop /usr/share/wayland-sessions/
```
