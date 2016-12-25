
# === {{CMD}}  dir
version () {
  local +x DIR="$1"; shift
  local +x BIN="$DIR"/nginx/sbin/nginx
  if [[ ! -e "$BIN" ]]; then
    return 1
  fi

  "$BIN" -V 2>&1
} # === end function
