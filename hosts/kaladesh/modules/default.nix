{
  imports = [
    ./home-assistant.nix
    ./nfs.nix
    ./traefik.nix
  ];
  virtualisation = {
    podman.enable = true;
    oci-containers.backend = "podman";
  };
}
