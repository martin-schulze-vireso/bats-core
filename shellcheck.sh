#!/usr/bin/env bash

set -e

targets=()
while IFS=  read -r -d $'\0'; do
    targets+=("$REPLY")
done < <(
  find \
    bin/bats \
    libexec/bats-core \
    lib/bats-core \
    shellcheck.sh \
    -type f \
    -print0
  )

for file in "${targets[@]}"; do
  [ -f "${file}" ] && LC_ALL=C.UTF-8 shellcheck -x "${file}" || status=1
done;

exit $status