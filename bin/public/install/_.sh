
# === {{CMD}}
# === {{CMD}}  --args --to configure
# === Include ---prefix to configure.
install () {

  local +x ORIGIN="$PWD"
  local +x TMP_DIR="$THIS_DIR/tmp"


  local +x LATEST_VER="$((git ls-remote -t https://github.com/openresty/openresty | cut -d'/' -f 3 | sort -r | grep -P '^v[0-9\.]+$' | head -n 1 | cut -d'v' -f2) || :)"
  local +x ARCHIVE="openresty-${LATEST_VER}.tar.gz"
  local +x SOURCE_DIR="openresty-${LATEST_VER}"

  mkdir -p "$TMP_DIR"
  cd "$TMP_DIR"
  download-file "$ARCHIVE"
  untar-file "$ARCHIVE" "$SOURCE_DIR"

  local +x PROCS="$(grep -c '^processor' /proc/cpuinfo)"
  cd "$SOURCE_DIR"
  ./configure   \
    --prefix="$PREFIX"             \
    --with-http_iconv_module       \
    --without-http_redis2_module   \
    --with-pcre-jit                \
    --with-luajit                  \
    --with-ipv6                    \
    --with-http_ssl_module         \
    -j$(($PROCS - 1))              \
    $@
  make
  make install
} # === end function

untar-file () {
  tar -xvf $1 >/dev/null && return 0
  rm $1
  rm -rf "$2"
  download-file $1 && untar-file $1 $2
}

download-file () {
  if [[ -e "$1" ]]; then
    echo "=== File already exists: $1"
    return 0
  fi
  wget --quiet "https://openresty.org/download/$1"
}


