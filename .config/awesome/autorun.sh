#!/usr/bin/env bash

run() {
  if ! pgrep -f "$1" ;
  then
    "$@"&
  fi
}

run autorandr -c
run nm-applet
run cbatticon
run pasystray -g
run polkit-dumb-agent
