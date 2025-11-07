{ ... }:
{
  virtualisation.oci-containers.containers.home-assistant = {
    hostname = "home-assistant";
    image = "ghcr.io/home-operations/home-assistant:2025.7.3";
    user = "1000:100";
    volumes = [
      "/home/eweishaar/containers/storage/home-assistant/config:/config"
    ];
    extraOptions = [ "--network=host" ];
  };
}
