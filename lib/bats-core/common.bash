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

# emulate `tee -a "$1" while filtering out interactive output
# we cannot simply use tee, because we can't be selective with its output for interactive vs normal output
# we also cannot bypass tee for the interactive output (e.g. via FD 3),
# because some of the normal output should also be interactive and putting some into tee and others into  FD3
# leads to races conditions
bats_filter_interactive_output() { # <output file>
  while read -r line; do
    # don't forward interactive output into output log
    if [[ "$line" != "bats_tap_stream_"* ]]; then
      echo "$line" >> "$1"
    fi
    echo "$line"
  done
}