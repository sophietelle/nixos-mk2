{
  programs.zed-editor = {
    enable = true;
    extensions = [ "fleet-themes" "colored-zed-icons-theme" ];

    mutableUserSettings = true;
    userSettings = {
      languages = {
        TypeScript = { language_servers = [ "tsgo" ]; };
        Nix = { language_servers = [ "nixd" "!nil" ]; };
      };

      window_decorations = "server";

      theme = "Fleet Dark";
      icon_theme = "Colored Zed Icons Theme Dark";
      base_keymap = "VSCode";

      buffer_font_family = "Iosevka";
      buffer_font_weight = 600;
      buffer_font_size = 16;

      ui_font_family = "Liberation Serif";
      ui_font_size = 17;

      active_pane_modifiers = { border_size = 0; inactive_opacity = 0.8; };

      tab_bar = { show = false; };
      toolbar = { quick_actions = false; };

      scrollbar = {
        selected_symbol = false;
        selected_text = false;
        git_diff = false;
        cursors = false;
      };

      title_bar = {
        show_onboarding_banner = false;
        show_user_picture = false;
      };
    };
  };
}
