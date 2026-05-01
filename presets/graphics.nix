{
  enable ? false,
  nvidia ? false,
  disablePrime ? false,
  enableNvidiaModesetting ? false,
}: { config, lib, ... }: {
  hardware.graphics = lib.mkIf enable {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = lib.mkIf nvidia ["nvidia"];

  hardware.nvidia = lib.mkIf nvidia {
    modesetting.enable = lib.mkIf enableNvidiaModesetting false;
    powerManagement.enable = true;

    open = true;
    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = lib.mkIf disablePrime {
      offload = {
        enable = false;
      };
    };
  };
}
