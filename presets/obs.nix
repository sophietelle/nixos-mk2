{
  enable ? false,
  useCUDA ? false,
  plugins ? [ ],
  useVirtualCamera ? false,
}: { pkgs, lib, ... }: {
  programs.obs-studio = lib.mkIf enable {
    enable = true;
    plugins = map (name: pkgs.obs-studio-plugins.${name}) plugins;
    enableVirtualCamera = lib.mkIf useVirtualCamera true;

    package = (
      pkgs.obs-studio.override {
        cudaSupport = useCUDA;
      }
    );
  };
}
