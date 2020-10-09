#!/usr/bin/env bash

# reads (extended) bats tap streams from stdin and calls callback functions for each line
# bats_tap_stream_plan <number of tests>                                      -> when the test plan is encountered
# bats_tap_stream_begin <test index> <test function name>                     -> when a new test's file evaluation is begun WARNING: extended only
# bats_tap_stream_setup <test index> <test name>                              -> when a new test's setup is begun WARNING: extended only
# bats_tap_stream_setup_finished <test index> <test name>                     -> when a new test's setup is finished WARNING: extended only
# bats_tap_stream_teardown <test index> <test name>                           -> when a new test's teardown is begun WARNING: extended only
# bats_tap_stream_exit_test <test index> <test name>                          -> when a test (including teardown) is finished WARNING: extended only
# bats_tap_stream_ok [--duration <milliseconds] <test index> <test name>      -> when a test was successful
# bats_tap_stream_not_ok [--duration <milliseconds>] <test index> <test name> -> when a test has failed
# bats_tap_stream_skipped <test index> <test name> <skip reason>              -> when a test was skipped
# bats_tap_stream_comment <comment text without leading '# '> <scope>         -> when a comment line was encountered, 
#                                                                                scope tells the last encountered function except this and bats_tap_stream_unknown
# bats_tap_stream_begin_file <file name>                                           -> when a new file is begun WARNING: extended only
# bats_tap_stream_setup_file <file name>                                      -> when the setup_file of a file is begun WARNING: extended only
# bats_tap_stream_teardown_file <file name>                                   -> when the teardown_file of a file is begun WARNING: extended only
# bats_tap_stream_exit_suite <file name>                                      -> when a suite is finished  WARNING: extended only
# bats_tap_stream_unknown <full line> <scope>                                 -> when a line is encountered that does not match the previous entries,
#                                                                                scope @see bats_tap_stream_comment
# forwards all input as is, when there is no TAP test plan header
function bats_parse_internal_extended_tap() {
    local header_pattern='[0-9]+\.\.[0-9]+'
    IFS= read -r header

    if [[ "$header" =~ $header_pattern ]]; then
        bats_tap_stream_plan "${header:3}"
    else
        # If the first line isn't a TAP plan, print it and pass the rest through
        printf '%s\n' "$header"
        exec cat
    fi

    ok_line_regexpr="ok ([0-9]+) (.*)"
    skip_line_regexpr="ok ([0-9]+) (.*) # skip( (.*))?$"
    not_ok_line_regexpr="not ok ([0-9]+) (.*)"

    timing_expr="in ([0-9]+)ms$"
    local test_name begin_index ok_index not_ok_index index scope old_scope 
    begin_index=0
    index=0
    scope=bats_tap_stream_plan
    line=''
    while true; do # allow for timeout on early lines
        while IFS= read -t 2 -r line; status=$?; [[ $status -eq 0 ]]; do
            old_scope="$scope"
            scope=${line%% *}
            case "$line" in
            'bats_tap_stream_begin '*) # this will only be called in extended tap output
                ((++begin_index))
                test_name="${line#* $begin_index }" # this can only be the function name
                bats_tap_stream_begin "$begin_index" "$test_name"
                ;;
            'bats_tap_stream_setup '*) # this will only be called in extended tap output
                test_name="${line#* $begin_index }" # now override function name from begin with actual name
                bats_tap_stream_setup "$begin_index" "$test_name"
                ;;
            'bats_tap_stream_setup_finished '*) # this will only be called in extended tap output
                bats_tap_stream_setup_finished  "$begin_index" "$test_name"
                ;;
            'ok '*)
                ((++index))
                scope=bats_tap_stream_ok
                if [[ "$line" =~ $ok_line_regexpr ]]; then
                    ok_index="${BASH_REMATCH[1]}"
                    test_name="${BASH_REMATCH[2]}"
                    if [[ "$line" =~ $skip_line_regexpr ]]; then
                        test_name="${BASH_REMATCH[2]}" # cut off name before "# skip"
                        local skip_reason="${BASH_REMATCH[4]}"
                        scope=bats_tap_stream_skipped
                        bats_tap_stream_skipped "$ok_index" "$test_name" "$skip_reason"
                    else
                        if [[ "$line" =~ $timing_expr ]]; then
                            bats_tap_stream_ok --duration "${BASH_REMATCH[1]}" "$ok_index" "$test_name"
                        else
                            bats_tap_stream_ok "$ok_index" "$test_name"
                        fi
                    fi
                else
                    printf "ERROR: could not match ok line: %s" "$line" >&2
                    exit 1
                fi
                ;;
            'not ok '*)
                ((++index))
                scope=bats_tap_stream_not_ok
                if [[ "$line" =~ $not_ok_line_regexpr ]]; then
                    not_ok_index="${BASH_REMATCH[1]}"
                    test_name="${BASH_REMATCH[2]}"
                    if [[ "$line" =~ $timing_expr ]]; then
                        bats_tap_stream_not_ok --duration "${BASH_REMATCH[1]}" "$not_ok_index" "$test_name"
                    else
                        bats_tap_stream_not_ok "$not_ok_index" "$test_name"
                    fi
                else
                    printf "ERROR: could not match not ok line: %s" "$line" >&2
                    exit 1
                fi
                ;;
            '# '*)
                scope="$old_scope" # comments don't change the scope
                bats_tap_stream_comment "${line:2}" "$scope"
                ;;
            'bats_tap_stream_teardown '*) # this will only be called in extended tap output
                bats_tap_stream_teardown "$begin_index" "$test_name"
                ;;
            'bats_tap_stream_exit_test '*) # this will only be called in extended tap output
                bats_tap_stream_exit_test  "$begin_index" "$test_name"
                ;;
            'bats_tap_stream_begin_file '*) # this will only be called in extended tap output
                # pass on the
                bats_tap_stream_begin_file "${line#bats_tap_stream_begin_file }"
                ;;
            'bats_tap_stream_exit_suite '*) # this will only be called in extended tap output
                bats_tap_stream_exit_suite "${line#bats_tap_stream_exit_suite }"
                ;;
            'bats_tap_stream_setup_file '*) # this will only be called in extended tap output
                bats_tap_stream_setup_file "${line#bats_tap_stream_setup_file }"
                ;;
            'bats_tap_stream_teardown_file '*) # this will only be called in extended tap output
                bats_tap_stream_teardown_file "${line#bats_tap_stream_teardown_file }"
                ;;
            *)
                scope="$old_scope" # unknown commands don't change the scope
                bats_tap_stream_unknown "$line" "$scope"
            ;;
            esac
        done
        if [[ $status -gt 128 ]]; then
            # left due to timeout -> try to slurp up remaining output
            line=''
            echo "Pulling low"
            while IFS= read -t 2 -r -n 1 char; do
                echo "char: $char"
                if [[ "$char" != $'\n' ]]; then
                    line+="$char"
                else
                    # if we suddenly encounter end of line, only consume this one
                    break
                fi
            done
            if [[ -n "$line" ]]; then
                bats_tap_stream_unknown "$line" "$scope"
            fi
        else
            # we did leave the read loop because of another reason than timeout
            # -> finish
            break
        fi
    done
}

# given a prefix and a path, remove the prefix if the path starts with it
# e.g. 
# remove_prefix /usr/bin /usr/bin/bash -> bash
# remove_prefix /usr /usr/lib/bash -> lib/bash
# remove_prefix /usr/bin /usr/local/bin/bash -> /usr/local/bin/bash
remove_prefix() {
  base_path="$1"
  path="$2"
  if [[ "$path" == "$base_path"* ]]; then
    # cut off the common prefix
    printf "%s" "${path:${#base_path}}"
  else
    printf "%s" "$path"
  fi
}
