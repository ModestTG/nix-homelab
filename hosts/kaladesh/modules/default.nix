{
  imports = [ ./home-assistant.nix ];
  virtualisation = {
    podman.enable = true;
    oci-containers.backend = "podman";
  };
}
