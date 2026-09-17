{ config, pkgs, ... }:

{
  # Fonts for Office & Systems customizations
  fonts.packages = with pkgs; [
     corefonts  # Arial, Times New Roman, Comic Sans, etc.
     vista-fonts # Calibri, Consolas, Constantia, etc.
  ];
  
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
    pkgs.papers   # For reading PDF from gnome (SOOO Good)
    pkgs.zed-editor-fhs
    osu-lazer-bin
    prismlauncher
    fastfetch
    pkgs.vscodium
    pkgs.neovim
    pkgs.lutris
#    pkgs.kdePackages.dolphin
#    pkgs.kdePackages.kate
    pkgs.davinci-resolve
    pkgs.obs-studio
    adwaita-icon-theme
    vanilla-dmz
#    gnome-themes-extra
#    gnome-tweaks
#    gnomeExtensions.vitals
#    gnomeExtensions.blur-my-shell
#    pkgs.gnomeExtensions.deperto-zoom-by-scroll
#    gnomeExtensions.wiggly
    pkgs.uv
    pkgs.freecad
    pkgs.rovium
    pkgs.anki
    easyeffects
    pkgs.chromium
    # For XFCE
    xfce.catfish
    xfce.gigolo
    xfce.orage
    xfce.xfburn
    xfce.xfce4-appfinder
    xfce.xfce4-clipman-plugin
    xfce.xfce4-cpugraph-plugin
    xfce.xfce4-dict
    xfce.xfce4-fsguard-plugin
    xfce.xfce4-genmon-plugin
    xfce.xfce4-netload-plugin
    xfce.xfce4-panel
    xfce.xfce4-pulseaudio-plugin
    xfce.xfce4-systemload-plugin
    xfce.xfce4-weather-plugin
    xfce.xfce4-whiskermenu-plugin
    xfce.xfce4-xkb-plugin
    xfce.xfdashboard
    font-manager
    pkgs.bun # All in one fast & easy-to-use tool. Instead of 1,000 node_modules for development, you only need bun.
    pkgs.home-manager # Home manager makes the packages installation in nixos more reproducible

  ];
  
  # Flatpak
  services.flatpak.enable = true;
}
