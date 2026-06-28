{
  enable ? false,
  useRegreet ? false,
  seamlessBoot ? false
}: { config, inputs, pkgs, lib, ... }: {
  services.greetd = {
    enable = lib.mkIf enable true;
    greeterManagesPlymouth = lib.mkIf seamlessBoot true;
  };

  programs.regreet = lib.mkIf useRegreet {
    enable = true;
  };
}
