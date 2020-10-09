#!/usr/bin/env bash

bats_extract_line() { # <file> <line number> <output variable name>
	local __bats_extract_line_line
	local __bats_extract_line_index=0

	while IFS= read -r __bats_extract_line_line; do
		if [[ "$((++__bats_extract_line_index))" -eq "$2" ]]; then
			printf -v "$3" '%s' "${__bats_extract_line_line%$'\r'}"
			return 0
		fi
	done <"$1"
	return 1
}

bats_strip_string() {
	[[ "$1" =~ ^[[:space:]]*(.*)[[:space:]]*$ ]]
	printf -v "$2" '%s' "${BASH_REMATCH[1]}"
}

# remove all bats_tap_stream_* lines
bats_filter_out_interactive_output() {
	while read -r line; do
		# don't forward interactive output into output log
		if [[ "$line" != "bats_tap_stream_"* ]]; then
			echo "$line"
		fi
	done
}