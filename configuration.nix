{ config, pkgs, callPackage, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./AutoUpdates.nix
  ];

  # LD FIX
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing library programs here not in environment system pkgs
  ];

  # Enable Flakes
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    max-jobs = 10;
    cores = 12;
  };

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    corefonts
    nerd-fonts.iosevka
    vista-fonts
  ];

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

  # Force pure X11 environment session type
  environment.sessionVariables = {
    XDG_SESSION_TYPE = "x11";
  };

  # Graphics & Desktop (XFCE + LightDM on X11)
  services.xserver = {
    enable = true;
    desktopManager.xfce.enable = true;
    displayManager.lightdm = {
      enable = true;
      greeters.gtk.enable = true;
    };
    videoDrivers = [ "nvidia" ];
  };
  services.displayManager.defaultSession = "xfce";

  # Ensure latest kernel & Intel Xe early module loading for Arrow Lake-S
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.kernelModules = [ "xe" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vpl-gpu-rt
    ];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;

    # Mandatory open kernel module for RTX 50 series (GB203)
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
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
    extraGroups = [ "networkmanager" "wheel" "docker" "vboxusers" ];
    packages = with pkgs; [
      mousepad
      thunderbird
    ];
  };

  # Packages & Programs
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    btop                 # System resource monitor
    nvtopPackages.full  # GPU process monitor
    libreoffice
    discord
    docker-compose
    obsidian
    steam
    typst         # Fast, modern academic paper renderer
    texliveFull   # Complete LaTeX engine
    pandoc        # Document conversion tool
    pkgs.zed-editor-fhs
    osu-lazer-bin
    prismlauncher
    fastfetch
    pkgs.vscodium
    pkgs.lutris
    pkgs.kdePackages.dolphin
    pkgs.obs-studio
    pkgs.kdePackages.kdenlive
  ];

  # VirtualBox
  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
  };

  programs.firefox.enable = true;
  programs.steam.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Virtualisation (Docker)
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

  # Ollama Service (CUDA enabled for RTX 5080)
  services.ollama = {
    enable = true;
    package = pkgs.ollama-cuda;
    host = "0.0.0.0";
    port = 11434;
    environmentVariables = {
      OLLAMA_ORIGINS = "*";
    };
  };

  # ACME Security
  security.acme = {
    acceptTerms = true;
    defaults.email = "lucas.chaleenon.poptie@gmail.com";
  };

  # Firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 11434 ];
    trustedInterfaces = [ "docker0" ];
  };

  system.stateVersion = "26.05";
}
