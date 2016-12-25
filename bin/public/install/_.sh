
# === {{CMD}}  --args --to-configure
# === The PREFIX is set to a relative path by default: ./progs/openresty
install () {

  local +x PREFIX="./progs/openresty"
  local +x ORIGIN="$PWD"
  local +x TMP_DIR="$THIS_DIR/tmp"

  local +x LATEST_VER="$((git ls-remote -t https://github.com/openresty/openresty | cut -d'/' -f 3 | sort -r | grep -P '^v[0-9\.]+$' | head -n 1 | cut -d'v' -f2) || :)"
  local +x ARCHIVE="openresty-${LATEST_VER}.tar.gz"
  local +x SOURCE_DIR="openresty-${LATEST_VER}"
  local +x PROCS="$(grep -c '^processor' /proc/cpuinfo)"

  mkdir -p "$TMP_DIR"; cd "$TMP_DIR"

  if [[ ! -d "$SOURCE_DIR" ]]; then
    download-file "$ARCHIVE"
    untar-file    "$ARCHIVE" "$SOURCE_DIR"
  fi

  cd "$SOURCE_DIR"
  ./configure \
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

  cd "$ORIGIN"
  mkdir -p progs
  if [[ -d "progs/openresty" ]]; then
    sh_color ORANGE "=== removing old OpenResty..."
    rm -rf "progs/openresty"
  fi
  mv -i "$TMP_DIR/$SOURCE_DIR/progs/openresty" "$ORIGIN/progs/openresty"

  cd progs/openresty/luajit/lib
  ln -s libluajit-5.1.so.2.1.0 libluajit-5.1.so.2
	cd "$ORIGIN"

  echo -n "=== Installed: "
  progs/openresty/nginx/sbin/nginx -v

} # === end function

untar-file () {
  { tar -xvf $1 >/dev/null && return 0; } || :
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


