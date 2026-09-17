{lib, pkgs, ...}:
{
  home = {
    packages = with pkgs; [
      hello
    ];

    username = "Lucas";
    homeDirectory = "/home/lucas";

    stateVersion = "23.11";
  };
}
