#!/usr/bin/env bash
set -u

agent="$(basename "$PWD")"
server="http://localhost:3000"
pkg="com.taziggg100.baylephilippeleopold"
apk="/tmp/bayle-universal.apk"
device=""

log() {
  printf '%s %s\n' "$(date '+%H:%M:%S')" "$*"
}

join_queue() {
  log "join queue"
  curl -sS -X POST "${server}/join?agent=${agent}" || true
  echo
}

release_queue() {
  log "release queue"
  curl -sS -X POST "${server}/done?agent=${agent}" || true
  echo
}

status_json() {
  curl -sS "${server}/status?agent=${agent}" || true
}

wait_turn() {
  while true; do
    local st
    st="$(status_json)"
    log "${st//$'\n'/ }"
    printf '%s' "$st" | grep -q '"yourTurn"[[:space:]]*:[[:space:]]*true' && return 0
    sleep 10
  done
}

still_turn() {
  status_json | grep -q '"yourTurn"[[:space:]]*:[[:space:]]*true'
}

first_device() {
  adb devices | awk 'NR>1 && $2=="device" {print $1; exit}'
}

any_emulator() {
  adb devices | awk 'NR>1 && $1 ~ /^emulator-/ {print $1; exit}'
}

wait_device() {
  local tries=0
  while [ "$tries" -lt 90 ]; do
    device="$(first_device)"
    if [ -n "$device" ]; then
      return 0
    fi
    sleep 2
    tries=$((tries + 1))
  done
  return 1
}

avd_name() {
  adb -s "$device" emu avd name 2>/dev/null | tr -d '\r' | sed -n '1p'
}

focus_is_app() {
  adb -s "$device" shell dumpsys window 2>/dev/null | grep -q "$pkg"
}

tap() {
  log "tap $1 $2"
  adb -s "$device" shell input tap "$1" "$2" || return 1
  sleep "${3:-2}"
}

back() {
  log "back"
  adb -s "$device" shell input keyevent KEYCODE_BACK || return 1
  sleep 2
}

capture() {
  local name="$1"
  log "capture $name"
  focus_is_app || {
    log "focus lost before $name"
    return 1
  }
  adb -s "$device" exec-out screencap -p > "docs/screens/${name}.png" || return 1
  sleep 2
}

attempt_capture() {
  log "adb devices before launch check"
  adb devices

  device="$(first_device)"
  if [ -z "$device" ]; then
    if [ -n "$(any_emulator)" ]; then
      log "an emulator is already listed by adb; waiting for another turn"
      return 1
    fi
    if pgrep -x qemu-system-x86_64 >/dev/null 2>&1 || pgrep -x qemu-system-aarch64 >/dev/null 2>&1; then
      log "an emulator process is already running; waiting for another turn"
      return 1
    fi
    log "no emulator device; launching Pixel_8_Pro"
    flutter emulators --launch Pixel_8_Pro || true
    wait_device || return 1
  fi

  log "device $device avd $(avd_name)"
  [ "$(avd_name)" = "Pixel_8_Pro" ] || return 1

  adb -s "$device" shell input keyevent KEYCODE_WAKEUP || true
  adb -s "$device" shell wm dismiss-keyguard || true

  still_turn || return 1

  log "install app"
  adb -s "$device" shell pm uninstall "$pkg" >/dev/null 2>&1 || true
  adb -s "$device" install -r "$apk" || return 1

  still_turn || return 1

  log "launch app"
  adb -s "$device" shell monkey -p "$pkg" -c android.intent.category.LAUNCHER 1 >/dev/null || return 1
  sleep 8
  focus_is_app || return 1

  still_turn || return 1
  focus_is_app || return 1

  rm -f docs/screens/*.png
  mkdir -p docs/screens

  capture 01_home || return 1
  tap 403 2845 2 || return 1
  capture 02_patrol || return 1
  tap 672 2845 2 || return 1
  capture 03_equipment || return 1
  tap 941 2845 2 || return 1
  capture 04_requests || return 1
  tap 1210 2845 2 || return 1
  capture 05_privacy || return 1

  local count unique
  count="$(find docs/screens -maxdepth 1 -type f -name '*.png' | wc -l | tr -d ' ')"
  unique="$(sha256sum docs/screens/*.png | awk '{print $1}' | sort -u | wc -l | tr -d ' ')"
  log "screens count=$count unique=$unique"
  [ "$count" -ge 5 ] && [ "$unique" -ge 5 ]
}

main() {
  while true; do
    join_queue
    wait_turn
    if attempt_capture; then
      log "uninstall app"
      adb -s "$device" shell pm uninstall "$pkg" >/dev/null 2>&1 || true
      release_queue
      log "screenshots complete"
      exit 0
    fi
    log "attempt failed or focus/turn lost"
    adb -s "${device:-emulator-5554}" shell pm uninstall "$pkg" >/dev/null 2>&1 || true
    release_queue
    sleep 10
  done
}

main "$@"
