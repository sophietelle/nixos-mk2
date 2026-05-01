{
  usePipewire ? false,
  useRtkit ? false,
  useAdditionalPackages ? false,
}: { lib, pkgs, ... }: {
  services.pipewire = lib.mkIf usePipewire {
    enable = true;

    pulse.enable = true;
    wireplumber.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };

  security.rtkit.enable = lib.mkIf useRtkit true;

  environment.systemPackages = lib.mkIf useAdditionalPackages [
    pkgs.pamixer
    pkgs.pavucontrol
  ];
}
