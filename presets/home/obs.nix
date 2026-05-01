{
  enable ? false,
  useCUDA ? false,
  plugins ? [ ],
}: { pkgs, lib, ... }: {
  programs.obs-studio = lib.mkIf enable {
    enable = true;
    plugins = map (name: pkgs.obs-studio-plugins.${name}) plugins;

    package = (
      pkgs.obs-studio.override {
        cudaSupport = useCUDA;
      }
    );
  };
}
