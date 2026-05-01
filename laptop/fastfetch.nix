{
  programs.fastfetch = {
    enable = true;
    settings = {
      modules = [
        "title"
        "separator"
        "os"
        "kernel"
        "packages"
        "shell"
        "wm"
        "terminal"
        "display"
        "cpu"
        "gpu"
        "memory"
        "break"
        "colors"
      ];
    };
  };
}
