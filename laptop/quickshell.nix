{ pkgs, ... }:

{
  home.packages = with pkgs; [
    quickshell
  ];

  # Lands at ~/.config/quickshell/{shell,Toast}.qml, so a bare `qs` runs it.
  xdg.configFile."quickshell" = {
    source = ./quickshell;
    recursive = true;
  };
}
