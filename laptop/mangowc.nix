{ pkgs, lib, ... }:

let
  mod = "SUPER";

  terminal = "alacritty";
  explorer = "thunar";
  launcher = "fuzzel";

  screenshot = "grimshot copy screen";
  windowshot = "grimshot copy anything";
in
{
  home.packages = with pkgs; [
    sway-contrib.grimshot
  ];

  wayland.windowManager.mango = {
    enable = true;

    autostart_sh = ''
      ${lib.getExe pkgs.swaybg} --image ${../wallpapers/ame.png} --mode fit &
    '';

    settings = {
      sloppyfocus = true;

      borderpx = 0;

      xkb_rules_layout = "us,ru,ua";
      xkb_rules_options = "grp:caps_toggle";

      gappih = 0;
      gappiv = 0;
      gappoh = 0;
      gappov = 0;

      animation_type_open="zoom";
      animation_type_close="zoom";
      zoom_initial_ratio=0.9;
      zoom_end_ratio=0.95;

      animation_curve_open="0.175,0.885,0.32,1.0";
      animation_curve_close="0.4,0.0,1.0,1.0";

      animation_duration_open=150;
      animation_duration_move=150;
      animation_duration_close=150;

      animation_fade_in=1;
      animation_fade_out=1;
      fadein_begin_opacity=0;
      fadeout_begin_opacity=0.5;

      allow_tearing = 2;

      focuscolor = "0x4d4e51ff";
      bordercolor = "0x00000000";
      urgentcolor = "0xeb4056ff";
      rootcolor = "0x18191bff";

      unfocused_opacity = 0.9;

      bind = [
        "${mod},Q,spawn,${terminal}"
        "${mod},E,spawn,${explorer}"
        "${mod},R,spawn,${launcher}"
        "${mod},C,killclient"
        "${mod},M,quit"
        "${mod},V,togglefloating"
        "${mod},J,switch_layout"

        "NONE,Print,spawn,${screenshot}"
        "ALT,Print,spawn,${windowshot}"

        "${mod}+SHIFT,Up,exchange_client,up"
        "${mod}+SHIFT,Down,exchange_client,down"
        "${mod}+SHIFT,Left,exchange_client,left"
        "${mod}+SHIFT,Right,exchange_client,right"

        "${mod},Up,focusdir,up"
        "${mod},Down,focusdir,down"
        "${mod},Left,focusdir,left"
        "${mod},Right,focusdir,right"

        "${mod},1,view,1"
        "${mod},2,view,2"
        "${mod},3,view,3"
        "${mod},4,view,4"
        "${mod},5,view,5"
        "${mod},6,view,6"
        "${mod},7,view,7"
        "${mod},8,view,8"
        "${mod},9,view,9"
        "${mod},0,view,9"

        "${mod}+SHIFT,1,tag,1"
        "${mod}+SHIFT,2,tag,2"
        "${mod}+SHIFT,3,tag,3"
        "${mod}+SHIFT,4,tag,4"
        "${mod}+SHIFT,5,tag,5"
        "${mod}+SHIFT,6,tag,6"
        "${mod}+SHIFT,7,tag,7"
        "${mod}+SHIFT,8,tag,8"
        "${mod}+SHIFT,9,tag,9"
        "${mod}+SHIFT,0,tag,9"

        "NONE,XF86AudioRaiseVolume,spawn,wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        "NONE,XF86AudioLowerVolume,spawn,wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        "NONE,XF86AudioMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        "SHIFT,XF86AudioMute,spawn,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        "NONE,XF86AudioNext,spawn,playerctl next"
        "NONE,XF86AudioPause,spawn,playerctl play-pause"
        "NONE,XF86AudioPlay,spawn,playerctl play-pause"
        "NONE,XF86AudioPrev,spawn,playerctl previous"

        "${mod},Z,setkeymode,resize"
        "${mod}+SHIFT,R,reload_config"
      ];

      keymode = {
        resize = {

          bind = [
            "NONE,Up,resizewin,0,-10"
            "NONE,Down,resizewin,0,+10"
            "NONE,Left,resizewin,-10,0"
            "NONE,Right,resizewin,+10,0"

            "NONE+Shift,Up,resizewin,0,-50"
            "NONE+Shift,Down,resizewin,0,+50"
            "NONE+Shift,Left,resizewin,-50,0"
            "NONE+Shift,Right,resizewin,+50,0"

            "NONE,Escape,setkeymode,default"
            "${mod},Z,setkeymode,default"
          ];
        };
      };
    };
  };
}
