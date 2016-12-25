
source "$THIS_DIR"/bin/public/version/_.sh

# === {{CMD}}  dir dir
is-same () {
  local +x A="$1"; shift
  local +x B="$1"; shift

  if [[ ! -d "$A" || ! -d "$B" ]]; then
    return 1
  fi

  local +x A_VERSION="$(version "$A" || :)"
  local +x B_VERSION="$(version "$B" || :)"

  if [[ "$A_VERSION" != "$B_VERSION" ]]; then
    return 1
  fi

  if [[ -z "$A_VERSION" || -z "$B_VERSION" ]]; then
    return 1
  fi

} # === end function

