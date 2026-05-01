{
  systemdBoot ? false,
  usePlymouth ? false,
  seamlessBoot ? false
}: { lib, ... }: {
  boot = {
    loader.systemd-boot.enable = lib.mkIf systemdBoot true;
    loader.efi.canTouchEfiVariables = lib.mkIf systemdBoot true;

    plymouth = lib.mkIf usePlymouth {
      enable = true;
      theme = "bgrt";
    };

    loader.timeout = lib.mkIf seamlessBoot 0;
    kernelParams = lib.mkIf seamlessBoot [
      "rd.systemd.show_status=auto"
      "quiet"
      "fbcon=vc:2-6"
    ];
  };
}
