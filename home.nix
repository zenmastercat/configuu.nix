{lib, pkgs, ...}:
{
  home = {
    packages = with pkgs; [
      cowsay lolcat
    ];

    username = "Lucas";
    homeDirectory = "/home/lucas";

    stateVersion = "23.11";
  };
}
