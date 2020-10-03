#!/usr/bin/env bats

load test_helper

INSTALL_DIR=
PATH_TO_INSTALL_SHELL=

setup() {
  make_bats_test_suite_tmpdir
  INSTALL_DIR="$BATS_TEST_SUITE_TMPDIR/bats-core"
  PATH_TO_INSTALL_SHELL="${BATS_TEST_DIRNAME%/*}/install.sh"
}

@test "install.sh creates a valid installation" {
  run "$PATH_TO_INSTALL_SHELL" "$INSTALL_DIR"
  [ "$status" -eq 0 ]
  [ "$output" == "Installed Bats to $INSTALL_DIR/bin/bats" ]
  [ -x "$INSTALL_DIR/bin/bats" ]
  [ -x "$INSTALL_DIR/libexec/bats-core/bats" ]
  [ -x "$INSTALL_DIR/libexec/bats-core/bats-exec-file" ]
  [ -x "$INSTALL_DIR/libexec/bats-core/bats-exec-suite" ]
  [ -x "$INSTALL_DIR/libexec/bats-core/bats-exec-test" ]
  [ -x "$INSTALL_DIR/libexec/bats-core/bats-format-cat" ]
  [ -x "$INSTALL_DIR/libexec/bats-core/bats-format-junit" ]
  [ -x "$INSTALL_DIR/libexec/bats-core/bats-format-pretty" ]
  [ -x "$INSTALL_DIR/libexec/bats-core/bats-format-tap" ]
  [ -x "$INSTALL_DIR/libexec/bats-core/bats-format-tap13" ]
  [ -x "$INSTALL_DIR/libexec/bats-core/bats-preprocess" ]
  [ -e "$INSTALL_DIR/lib/bats-core/common.bash" ]
  [ -e "$INSTALL_DIR/lib/bats-core/formatter.bash" ]
  [ -e "$INSTALL_DIR/lib/bats-core/preprocessing.bash" ]
  [ -e "$INSTALL_DIR/lib/bats-core/semaphore.bash" ]
  [ -e "$INSTALL_DIR/lib/bats-core/test_functions.bash" ]
  [ -e "$INSTALL_DIR/lib/bats-core/tracing.bash" ]
  [ -e "$INSTALL_DIR/lib/bats-core/validator.bash" ]
  [ -f "$INSTALL_DIR/share/man/man1/bats.1" ]
  [ -f "$INSTALL_DIR/share/man/man7/bats.7" ]

  run "$INSTALL_DIR/bin/bats" -v
  [ "$status" -eq 0 ]
  [ "${output%% *}" == 'Bats' ]
}

@test "install.sh only updates permissions for Bats files" {
  mkdir -p "$INSTALL_DIR"/{bin,libexec/bats-core}

  local dummy_bin="$INSTALL_DIR/bin/dummy"
  printf 'dummy' >"$dummy_bin"

  local dummy_libexec="$INSTALL_DIR/libexec/bats-core/dummy"
  printf 'dummy' >"$dummy_libexec"

  run "$PATH_TO_INSTALL_SHELL" "$INSTALL_DIR"
  [ "$status" -eq 0 ]
  [ -f "$dummy_bin" ]
  [ ! -x "$dummy_bin" ]
  [ -f "$dummy_libexec" ]
  [ ! -x "$dummy_libexec" ]
}

@test "bin/bats is resilient to symbolic links" {
  run "$PATH_TO_INSTALL_SHELL" "$INSTALL_DIR"
  [ "$status" -eq 0 ]

  # Simulate a symlink to bin/bats (without using a symlink, for Windows sake)
  # by creating a wrapper script that executes bin/bats via a relative path.
  #
  # root.bats contains tests that use real symlinks on platforms that support
  # them, as does the .travis.yml script that exercises the Dockerfile.
  local bats_symlink="$INSTALL_DIR/bin/bats-link"
  printf '%s\n' '#! /usr/bin/env bash' \
    "cd '$INSTALL_DIR/bin'" \
    './bats "$@"' >"$bats_symlink"
  chmod 700 "$bats_symlink"

  run "$bats_symlink" -v
  [ "$status" -eq 0 ]
  [ "${output%% *}" == 'Bats' ]
}
