{
  enableBrightnessKeys ? true
}: { lib, ... }: {
  services.illum.enable = lib.mkIf enableBrightnessKeys true;
}
