
source "$THIS_DIR/bin/public/available/_.sh"

# === {{CMD}}  --args --to-configure
# === The PREFIX is set to a relative path by default: $PWD/progs/openresty
# === NOTE: NGINX error-log-path is set to $PWD/tmp/openresty.error.log.
# ===       See: https://trac.nginx.org/nginx/ticket/147
install () {

  local +x ORIGIN="$PWD"
  local +x PREFIX="$ORIGIN/progs/openresty"
  local +x TMP_DIR="$THIS_DIR/tmp"

  local +x LATEST_VER="$((available | head -n 1) || :)"
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
                                   \
    --with-http_iconv_module       \
    --with-pcre-jit                \
    --with-luajit                  \
    --with-ipv6                    \
    --with-http_ssl_module         \
                                   \
    --without-http_redis2_module   \
    --without-mail_pop3_module     \
    --without-mail_imap_module     \
    --without-mail_smtp_module     \
                                   \
    --error-log-path="$ORIGIN/tmp/openresty.error.log" \
    --http-log-path="$ORIGIN/tmp/openresty.access.log" \
    -j$(($PROCS - 1))              \
    $@
  make
  make install

  cd "$ORIGIN/progs/openresty/luajit/lib"
  if [[ -e libluajit-5.1.so.2 ]]; then
    echo "=== Skipping fix: linking libluajit-5.1.so.2.1.0"
  else
    ln -s libluajit-5.1.so.2.1.0 libluajit-5.1.so.2
  fi
	cd "$ORIGIN"

  echo -n "=== Installed: "
  progs/openresty/nginx/sbin/nginx -v

} # === end function

untar-file () {
  sh_color ORANGE "=== Extracting: {{$1}}"
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
  sh_color ORANGE "=== Downloading: {{$1}}"
  wget --quiet "https://openresty.org/download/$1"
}


