#!/usr/bin/env bats

echo "outside any functions: stdout"

setup_file() {
	echo "setup_file: FD3" >&3
	echo "setup_file: stdout"
}

teardown_file() {
	echo "teardown_file: FD3" >&3
	echo "teardown_file: stdout"
}

setup() {
	echo "$BATS_TEST_DESCRIPTION setup: FD3" >&3
	echo "$BATS_TEST_DESCRIPTION setup: stdout"
}

teardown() {
	echo "$BATS_TEST_DESCRIPTION teardown: FD3" >&3
	echo "$BATS_TEST_DESCRIPTION teardown: stdout"
}

@test "successful test" {
	echo "$BATS_TEST_DESCRIPTION: FD3" >&3
	echo "$BATS_TEST_DESCRIPTION: stdout"
	run echo "$BATS_TEST_DESCRIPTION: run"
}

@test "failing test" {
	echo "$BATS_TEST_DESCRIPTION: FD3" >&3
	echo "$BATS_TEST_DESCRIPTION: stdout"
	run echo "$BATS_TEST_DESCRIPTION: run"
	false
}
