#!/usr/bin/env bash

set -ex

bats_tap_stream_begin_file "$BATS_FIXTURE_ROOT/failing.bats"
bats_tap_stream_line 7 "$BATS_FIXTURE_ROOT/failing.bats"
bats_tap_stream_setup_file "$BATS_FIXTURE_ROOT/failing.bats"
bats_tap_stream_begin 1 test_a_failing_test
bats_tap_stream_line 7 "$BATS_FIXTURE_ROOT/failing.bats"
bats_tap_stream_line 1 "$BATS_FIXTURE_ROOT/failing.bats"
bats_tap_stream_line 1 "$BATS_FIXTURE_ROOT/failing.bats"
bats_tap_stream_setup 1 a failing test
bats_tap_stream_setup_finished 1 a failing test
bats_tap_stream_line 2 "$BATS_FIXTURE_ROOT/failing.bats"
bats_tap_stream_line 3 "$BATS_FIXTURE_ROOT/failing.bats"
bats_tap_stream_line 4 "$BATS_FIXTURE_ROOT/failing.bats"
bats_tap_stream_line 4 "$BATS_FIXTURE_ROOT/failing.bats"
bats_tap_stream_line 4 "$BATS_FIXTURE_ROOT/failing.bats"
bats_tap_stream_line 1 "$BATS_FIXTURE_ROOT/failing.bats"
bats_tap_stream_teardown 1
not ok 1 a failing test
bats_tap_stream_comment "(in test file test/fixtures/bats/failing.bats, line 4)"
bats_tap_stream_comment '  `eval "( exit ${STATUS:-1} )"\'' failed'

bats_tap_stream_exit_test 1
bats_tap_stream_teardown_file "$BATS_FIXTURE_ROOT/failing.bats"
bats_tap_stream_exit_suite "$BATS_FIXTURE_ROOT/failing.bats"