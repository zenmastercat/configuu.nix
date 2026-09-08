{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./AutoUpdates.nix
  ];
  # Enable automatic garbage collection - please use!
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };
  # Weekly store deduplication / optimization
  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };
  # LD FIX
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing library programs here not in environment system pkgs
  ];
  # Enable Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
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

  # Display Manager & Desktop Manager (GNOME)
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    videoDrivers = [ "nvidia" ];
  };
    environment.sessionVariables = {
      MUTTER_DEBUG_DISABLE_HW_CURSOR = "1";
      XCURSOR_THEME = "Vanilla-DMZ";
      XCURSOR_SIZE = "24";
  };
  # Set dconf settings to apply the cursor theme by default
  programs.dconf.profiles.user.databases = [ {
    settings."org/gnome/desktop/interface".cursor-theme = "Vanilla-DMZ";
  } ];

  # Fix black screen after SYSTEMD_SLEEP_FREEZE_USER_SESSIONS
  boot.kernelParams = [ "nvidia-drm.preserve_video_memory_allocations=1" ];

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
    powerManagement.enable = true;
    powerManagement.finegrained = false;

    # Mandatory open kernel module for RTX 50 series (GB203)
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    # NVIDIA PRIME Offload Settings
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true; # Adds the `nvidia-offload` wrapper command to PATH
      };

      # Update these string values with your actual PCI Bus IDs from Step 1
      intelBusId = "PCI:0:2:0";   
      nvidiaBusId = "PCI:1:0:0";  
    };

  };
  systemd.services."systemd-suspend" = {
    serviceConfig = {
      Environment = "SYSTEMD_SLEEP_FREEZE_USER_SESSIONS=false";
    };
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
  # Permanent Passwordless Sudo / Admin Access for Wheel Group
  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
  };

  # Packages & Programs
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    git
    vim
    wget
    btop                 # System resource monitor
    nvtopPackages.full   # GPU process monitor
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
    pkgs.kdePackages.kate
    pkgs.obs-studio
    pkgs.kdePackages.kdenlive
    adwaita-icon-theme
    vanilla-dmz
    gnome-themes-extra
    gnome-tweaks
    gnomeExtensions.vitals
    gnomeExtensions.blur-my-shell
    gnomeExtensions.wiggly
    pkgs.uv
    pkgs.rovium
  ];

  # VirtualBox
  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true;
  };

  programs.firefox.enable = true;
  programs.steam = {
    enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
    gamescopeSession.enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };
  programs.java.enable = true;
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
