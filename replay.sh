while IFS= read -d $'\x00' -rn 1 c; do
       printf '%s' "$c"
       sleep 0.01
done < test/fixtures/pretty-formatter/test.bats.expected.log
