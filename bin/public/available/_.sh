
# === {{CMD}}  # List avaiable versions (ie tags) from repo.
available () {
  git ls-remote -t https://github.com/openresty/openresty | cut -d'/' -f 3 | sort -r | grep -P '^v[0-9\.]+$' | sort --version-sort --reverse | cut -d'v' -f2
} # === end function
