{
  imports = [
    ./home-assistant.nix
    ./traefik.nix
  ];
  virtualisation = {
    podman.enable = true;
    oci-containers.backend = "podman";
  };
}
