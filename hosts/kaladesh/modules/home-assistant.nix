{ config, ... }:
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
  services.traefik.dynamicConfigOptions.http = {
    routers.home-assistant = {
      entrypoints = [ "websecure" ];
      rule = "Host(`hass.ewhomelab.com`)";
      tls.certResolver = "letsencrypt";
      service = "home-assistant";
    };
    services.home-assistant.loadBalancer.servers = [
      {
        url = "http://localhost:8123";
      }
    ];
  };
  age.secrets.restic-password.file = ../../../secrets/restic-password.age;
  services.restic.backups.home-assistant = {
    repository = "sftp:root@10.0.0.8:/mnt/AuxPool/K8S-NFS/backups/home-assistant";
    paths = [ "/home/eweishaar/containers/storage/home-assistant" ];
    passwordFile = config.age.secrets.restic-password.path;
    initialize = true;
    pruneOpts = [
      "--keep-daily 14"
      "--keep-monthly 6"
      "--keep-yearly 1"
    ];
  };
}
