#Based version : v0.2.2
# River KWM NixOS Module

This repo is a  module for nixos to easyly install **River** Wayland compositor with kwm windowmanager, featuring a custom **Zig-based window manager (kwm)**. This project automates the build process, environment setup, and session integration.



# Official repo kwm
[https://github.com/kewuaa/kwm]

## ✨ Features

*   **Native Zig Build**: Compiles `kwm` from source using Nix's sandboxed build environment.
*   **Plug-and-Play Session**: Automatically generates a `river-kwm.desktop` session entry for GDM, SDDM, or Ly.
*   **Curated Environment**: Bundles essential Wayland tools (`foot`, `wmenu`, `wl-clipboard`) out of the box.
*   **Modular Architecture**: Easily integrable into any NixOS flake-based configuration.

---

## 🚀 Installation

Add this flake to your system configuration using the following steps:

### 1. Update `flake.nix`

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
