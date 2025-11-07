{ config, ... }:
{
  age.secrets.cf-dns-api-token = {
    file = ../../../secrets/cf-dns-api-token.age;
    owner = config.services.traefik.group;
    group = config.services.traefik.group;
  };
  systemd.services.traefik.serviceConfig.EnvironmentFile = [
    config.age.secrets.cf-dns-api-token.path
  ];

  services.traefik = {
    enable = true;
    staticConfigOptions = {
      global = {
        checkNewVersion = false;
        sendAnonymousUsage = false;
      };
      entryPoints = {
        web = {
          address = ":80";
          http.redirections.entrypoint = {
            to = "websecure";
            scheme = "https";
          };
        };
        websecure = {
          address = ":443";
          http.tls = {
            certResolver = "letsencrypt";
            domains = [
              {
                main = "ewhomelab.com";
                sans = "*.ewhomelab.com";
              }
            ];
          };
        };
      };
      log = {
        level = "INFO";
        format = "json";
      };
      certificatesResolvers.letsencrypt.acme = {
        email = "elliotweishaar27@gmail.com";
        caServer = "https://acme-staging-v02.api.letsencrypt.org/directory";
        storage = "${config.services.traefik.dataDir}/acme.json";
        dnsChallenge = {
          provider = "cloudflare";
          resolvers = [
            "1.1.1.1:53"
            "1.0.0.1:53"
          ];
          propagation.delayBeforeChecks = 60;
        };
      };
      api.dashboard = true;
    };
    dynamicConfigOptions.http = {
      routers = {
        api = {
          rule = "Host(`traefik-int.ewhomelab.com`)";
          service = "api@internal";
          entrypoints = [ "websecure" ];
        };
      };
    };
  };
}
