#!/usr/bin/env bats

bats_require_minimum_version 1.5.0

setup() {
    load test_helper
    fixtures tagging
}

@test "No tag filter runs all tests" {
    run -0 bats "$FIXTURE_ROOT/tagged.bats"
    [ "${lines[0]}" == "1..5" ]
    [ "${lines[1]}" == "ok 1 No tags" ]
    [ "${lines[2]}" == "ok 2 Only file tags" ]
    [ "${lines[3]}" == "ok 3 File and test tags" ]
    [ "${lines[4]}" == "ok 4 File and other test tags" ]
    [ "${lines[5]}" == "ok 5 Only test tags" ]
    [ ${#lines[@]} -eq 6 ]
}

@test "Empty tag filter runs tests without tag" {
    run -0 bats --filter-tags '' "$FIXTURE_ROOT/tagged.bats"
    [ "${lines[0]}" == "1..1" ]
    [ "${lines[1]}" == "ok 1 No tags" ]
    [ ${#lines[@]} -eq 2 ]
}

@test "--filter-tags (also) selects tests that contain additional tags" {
    run -0 bats --filter-tags 'file:tag:1' "$FIXTURE_ROOT/tagged.bats"
    [ "${lines[0]}" == "1..3" ]
    [ "${lines[1]}" == "ok 1 Only file tags" ]
    [ "${lines[2]}" == "ok 2 File and test tags" ]
    [ "${lines[3]}" == "ok 3 File and other test tags" ]
    [ ${#lines[@]} -eq 4 ]
}

@test "--filter-tags only selects tests that match all tags (logic and)" {
    run -0 bats --filter-tags 'test:tag:1,file:tag:1' "$FIXTURE_ROOT/tagged.bats"
    [ "${lines[0]}" == "1..1" ]
    [ "${lines[1]}" == "ok 1 File and test tags" ]
    [ ${#lines[@]} -eq 2 ]
}

@test "multiple --filter-tags work as logical or" {
    run -0 bats --filter-tags 'test:tag:1,file:tag:1' --filter-tags 'test:tag:2,file:tag:1' "$FIXTURE_ROOT/tagged.bats"
    [ "${lines[0]}" == "1..2" ]
    [ "${lines[1]}" == "ok 1 File and test tags" ]
    [ "${lines[2]}" == "ok 2 File and other test tags" ]
    [ ${#lines[@]} -eq 3 ]
}

@test "--filter-tags order of tags does not matter" {
    # note the reversed order in comparison to test above
    run -0 bats --filter-tags 'file:tag:1,test:tag:1' "$FIXTURE_ROOT/tagged.bats"
    [ "${lines[0]}" == "1..1" ]
    [ "${lines[1]}" == "ok 1 File and test tags" ]
    [ ${#lines[@]} -eq 2 ]
}