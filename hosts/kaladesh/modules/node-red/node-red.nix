{ config, ... }:
{
  services.node-red = {
    enable = true;
    withNpmAndGcc = true;
    configFile = ./settings.js;
  };
  services.traefik.dynamicConfigOptions.http = {
    routers.node-red = {
      entrypoints = [ "websecure" ];
      rule = "Host(`node-red.ewhomelab.com`)";
      tls.certResolver = "letsencrypt";
      service = "node-red";
    };
    services.node-red.loadBalancer.servers = [
      {
        url = "http://localhost:1880";
      }
    ];
  };
  age.secrets.restic-password.file = ../../../../secrets/restic-password.age;
  services.restic.backups.node-red = {
    repository = "sftp:root@10.0.0.8:/mnt/AuxPool/K8S-NFS/backups/node-red";
    paths = [ "/var/lib/node-red" ];
    passwordFile = config.age.secrets.restic-password.path;
    initialize = true;
    pruneOpts = [
      "--keep-daily 14"
      "--keep-monthly 6"
      "--keep-yearly 1"
    ];
  };
}
