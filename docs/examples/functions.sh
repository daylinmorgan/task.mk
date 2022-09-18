#!/usr/bin/env bash

msg() {
  printf '%s\n' "$1" | pv -qL 12
  sleep 1
}

cmd (){
  clear
  printf 'bash >> '
  msg "$1"
  $1
  sleep 2
}

