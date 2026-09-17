{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./AutoUpdates.nix
  ];
  #LD FIX
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    #add any missing library
    #programs here not in environment system pkgs
  ];

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Time & Locale
  time.timeZone = "Asia/Bangkok";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Graphics & Desktop
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
  };

  # Audio & Core Services
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.printing.enable = true;
  services.openssh.enable = true;

  # User Account
  users.users.lucas = {
    isNormalUser = true;
    description = "Lucas";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      kdePackages.kate
      thunderbird
    ];
  };

  # Packages & Programs
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    btop
    libreoffice
    discord
    docker-compose
    steam
  ];

  programs.firefox.enable = true;
  programs.steam.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Virtualisation (Docker only)
  virtualisation.docker.enable = true;

  # SearXNG Service
  services.searx = {
    enable = true;
    package = pkgs.searxng;
    redisCreateLocally = true;
    environmentFile = "/var/lib/searx/searxng.env";
    settings = {
      server = {
        port = 8080;
        bind_address = "127.0.0.1";
      };
      general = {
        debug = false;
        instance_name = "My SearXNG Engine";
      };
      search = {
        safe_search = 0;
        autocomplete = "google";
      };
    };
  };

  # ACME Security
  security.acme = {
    acceptTerms = true;
    defaults.email = "lucas.chaleenon.poptie@gmail.com";
  };

  system.stateVersion = "26.05";
}
