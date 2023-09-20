#!/usr/bin/env bash

run() {
  if ! pgrep -f "$1" ;
  then
    "$@"&        wibox.widget.systray({
          set_reverse = true
        }),
  fi
}

run autorandr -c
run nm-applet
run pasystray -g
run polkit-dumb-agent
