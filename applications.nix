{ config, pkgs, ... }:

{
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
    pkgs.neovim
    pkgs.lutris
    pkgs.kdePackages.dolphin
    pkgs.kdePackages.kate
    pkgs.davinci-resolve
    pkgs.obs-studio
    adwaita-icon-theme
    vanilla-dmz
    gnome-themes-extra
    gnome-tweaks
    gnomeExtensions.vitals
    gnomeExtensions.blur-my-shell
    pkgs.gnomeExtensions.deperto-zoom-by-scroll
    gnomeExtensions.wiggly
    pkgs.uv
    pkgs.freecad
    pkgs.rovium
    pkgs.anki
    easyeffects
  ];
  
  # Flatpak
  services.flatpak.enable = true;
}
