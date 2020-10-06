#!/usr/bin/env bats

load test_helper
fixtures pretty-formatter

@test "interactive mode" {
    make_bats_test_suite_tmpdir
    output_directory="$BATS_TEST_SUITE_TMPDIR/$BATS_TEST_NAME"
    mkdir -p "$output_directory"
    # store the extended tap stream of running test.bats in a file
    run bats --pretty --interactive --output "$output_directory" --report-formatter cat "$FIXTURE_ROOT/test.bats"
    report_file="$output_directory/report.log"
    # did we create it?
    [[ -e "$report_file" ]]

    script_output="$output_directory/script.log"

    export BATS_ROOT
    export BATS_INTERACTIVE_OUTPUT=1
    # now replay bats-format-pretty
    run bash -c "script '$script_output' -c \"$BATS_ROOT/libexec/bats-core/bats-format-pretty $flags < '$report_file' \""
    # remove script's leading/trailing line
    cleaned_script_output="$output_directory/cleaned_script.log"
    head -n -1 <"$script_output" | tail -n +2 > "$cleaned_script_output"

    cp "$cleaned_script_output" "$FIXTURE_ROOT/test.bats.expected.log"
    # inspect the replay via
    # head -n -12 test/fixtures/pretty-formatter/test.bats.expected.log 
    # animated replay:
    # while IFS= read -d $'\x00' -rn 1 c; do printf "%s" "$c"; sleep 0.01; done < test/fixtures/pretty-formatter/test.bats.expected.log
}