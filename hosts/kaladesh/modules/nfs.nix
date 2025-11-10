{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ nfs-utils ];
  services.rpcbind.enable = true;
  boot.supportedFilesystems = [ "nfs" ];
  fileSystems =
    let
      nfsServer = "10.0.0.8";
      options = [
        "x-systemd.automount"
        "noauto"
      ];
      fsType = "nfs";
    in
    {
      "/mnt/k8s-nfs" = {
        device = nfsServer + ":/mnt/AuxPool/K8S-NFS";
        inherit fsType options;
      };
    };
}
