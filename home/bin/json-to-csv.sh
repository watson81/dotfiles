#!/usr/bin/env sh
jq -r -s '(map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols , $rows[] | @csv' "$@"
