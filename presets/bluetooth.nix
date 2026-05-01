{
  enable ? false,
  useOverskride ? false,
  useBlueman ? false
}: { lib, pkgs, ... }: {
  hardware.bluetooth = lib.mkIf enable {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = lib.mkIf useBlueman true;
  environment.systemPackages = lib.mkIf useOverskride [
    pkgs.overskride
  ];
}
