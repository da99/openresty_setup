
# === {{CMD}}
test () {

  cd /tmp
  local +x DIR="test_openresty_setup_install"
  rm -rf "$DIR"
  mkdir -p "$DIR"
  cd "$DIR"
  sh_color ORANGE "=== in {{$PWD}}"
#  mkdir -p progs
  $0 install || {
    local +x STAT=$?
    sh_color RED "!!! {{Failed}}: $STAT"
    exit $STAT
  }
} # === end function
