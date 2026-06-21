{
  enable ? false,
  useRegreet ? false,
  seamlessBoot ? false
}: { config, inputs, pkgs, lib, ... }: let
  mangoPkg = inputs.mango.packages.${pkgs.stdenv.hostPlatform.system}.mango;

  mangoGreetdConfig = pkgs.writeText "mango-greetd.conf" ''
    borderpx=0
    gappih=0
    gappiv=0
    gappoh=0
    gappov=0
    animations=0
  '';

  greeterStartup = pkgs.writeShellScript "mango-regreet-startup" ''
    ${lib.getExe pkgs.regreet}
    ${mangoPkg}/bin/mmsg -q
  '';
in {
  services.greetd = {
    enable = lib.mkIf enable true;
    greeterManagesPlymouth = lib.mkIf seamlessBoot true;
  };

  programs.regreet = lib.mkIf useRegreet {
    enable = true;
  };

  services.greetd.settings = lib.mkIf useRegreet {
    default_session.command = lib.mkForce
      "${lib.getExe mangoPkg} -c ${mangoGreetdConfig} -s ${greeterStartup}";
  };
}
