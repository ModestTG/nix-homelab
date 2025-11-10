{
  config,
  pkgs,
  ...
}:

let
  sshKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIElkoT9GhRczgqRRpdC4gfw/z1eShyqto4AKQnk3nka6" ];
in
{
  imports = [
    ./hardware-configuration.nix
    ./disko-config.nix
    ./modules/default.nix
  ];

  ### NixOS configuration
  age.secrets = {
    kaladesh-ssh-privateKey = {
      file = ../../secrets/kaladesh-ssh-privateKey.age;
      mode = "600";
      owner = "eweishaar";
      group = "users";
    };
  };
  hardware = {
    nvidia = {
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      nvidiaPersistenced = true;
    };
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        cudatoolkit
      ];
    };
    nvidia-container-toolkit.enable = true;
  };
  environment.systemPackages = with pkgs; [
    coreutils
    cudatoolkit
    curl
    dig
    file
    findutils
    jq
    nmap
    tree
    unrar
    unzip
    wget
    zip
  ];
  programs = {
    neovim.enable = true;
    ssh = {
      startAgent = true;
      extraConfig = ''
        AddKeysToAgent yes
        IdentityFile ${config.age.secrets.kaladesh-ssh-privateKey.path}
      '';
    };
  };
  boot = {
    loader = {
      grub.enable = false;
      systemd-boot = {
        enable = true;
        configurationLimit = 20;
      };
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
    };
  };
  time.timeZone = "America/Chicago";
  networking = {
    hostName = "kaladesh";
    firewall.enable = false;
    networkmanager.enable = true;
    enableIPv6 = false;
  };
  users = {
    mutableUsers = false;
    users.eweishaar = {
      # generated with `mkpasswd -m scrypt`
      initialHashedPassword = "$7$CU..../....i89TMSGgWw3qQucMUF3WQ/$NbRbMXyTiIM2jMaxKS1vHhTtZ1M7SgbB16eltu2ZYk7";
      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "podman"
        "wheel"
      ];
      uid = 1000;
      openssh.authorizedKeys.keys = sshKeys;
    };
    users.deploy = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
      ];
      openssh.authorizedKeys.keys = sshKeys;
    };
  };
  nix = {
    optimise = {
      automatic = true;
      dates = [ "03:00" ];
    };
    settings.trusted-users = [
      "eweishaar"
      "deploy"
    ];
  };
  nixpkgs.config.allowUnfree = true;
  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "yes";
        KexAlgorithms = [
          "sntrup761x25519-sha512@openssh.com"
          "curve25519-sha256"
          "curve25519-sha256@libssh.org"
          "diffie-hellman-group18-sha512"
          "diffie-hellman-group-exchange-sha256"
          "diffie-hellman-group14-sha256"
        ];
      };
    };
  };
  security = {
    pam = {
      sshAgentAuth.enable = true;
    };
    sudo = {
      extraRules = [
        {
          users = [ "eweishaar" ];
          commands = [ "ALL" ];
        }
        {
          users = [ "deploy" ];
          commands = [
            {
              command = "ALL";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    };
  };
  virtualisation = {
    podman.enable = true;
    oci-containers.backend = "podman";
  };
  system.stateVersion = "25.05";
}
