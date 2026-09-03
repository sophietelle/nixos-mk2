{
  logo = {
    type = "none";
  };
  display = {
    separator = " ";
    key.paddingLeft = 1;
  };
  modules = [
    "os"
    "kernel"
    "wm"
    "terminal"
    {
      type = "display";
      key = "Display {index}";
    }
    "cpu"
    "gpu"
    "memory"
  ];
}
