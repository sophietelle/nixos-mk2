{ pkgs, ... }:

{
  home.packages = with pkgs; [
    quickshell
  ];

  # Lands at ~/.config/quickshell/*.qml, so a bare `qs` runs shell.qml.
  xdg.configFile."quickshell" = {
    source = ./quickshell;
    recursive = true;
  };
}
