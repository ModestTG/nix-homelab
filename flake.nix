{
  description = "EWHS Homelab Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    hardware.url = "github:nixos/nixos-hardware";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    colmena.url = "github:zhaofengli/colmena";
  };
  outputs =
    {
      colmena,
      nixpkgs,
      self,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      colmenaHive = colmena.lib.makeHive self.outputs.colmena;
      colmena = {
        meta = {
          nixpkgs = import nixpkgs {
            inherit system;
          };
          specialArgs = { inherit inputs; };
        };
        kaladesh = {
          deployment = {
            targetHost = "kaladesh";
            targetUser = "deploy";
            tags = [ "server" ];
          };
          imports = [
            ./hosts/kaladesh/default.nix
            inputs.disko.nixosModules.disko
            inputs.hardware.nixosModules.common-cpu-intel
            inputs.hardware.nixosModules.common-gpu-nvidia-nonprime
            inputs.hardware.nixosModules.common-pc-ssd
          ];
        };
      };
      # Here specifically for nix repl eval
      nixosConfigurations = {
        kaladesh = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          inherit system;
          modules = [
            ./hosts/kaladesh
            inputs.disko.nixosModules.disko
            inputs.hardware.nixosModules.common-cpu-intel
            inputs.hardware.nixosModules.common-gpu-nvidia-nonprime
            inputs.hardware.nixosModules.common-pc-ssd
          ];
        };
      };
    };
}
