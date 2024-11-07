#!/usr/bin/env bash

function print_usage {
    cat <<EOF >&2
Usage: json-to-csv.sh [-t|--tsv|-c|--csv] [input.json]
Converts JSON objects into a CSV file. If no file is provided, reads from stdin.
 -c, --csv  [default] output as CSV (comma-separated values)
 -t, --tsv            output as TSV (tab-separated values)

Input should be one or more json objects, optionally in an array.
example input:
  [ { "name": "John Doe", "age": 30, "city": "New York" }, { "name": "Jane Doe", "age": 25 } ]
example output:
  "age","city","name"
  30,"New York","John Doe"
  25,,"Jane Doe"
EOF
}

for arg in "$@"; do
    case "${arg}" in
        -h|--help)
            print_usage
            exit 0
            ;;
        -t|--tsv)
            FORMAT="@tsv"
            ;;
        -c|--csv)
            FORMAT="@csv"
            ;;
        *)
            if [ -n "${INPUT}" ]; then
                echo "Too many arguments" >&2
                print_usage
                exit 1
            elif [ -r "${arg}" ]; then
                INPUT=${arg}
            else
                echo "File not found or not readable: ${arg}" >&2
                print_usage
                exit 1
            fi
            ;;
    esac
done

hash jq 2>/dev/null || { echo "jq is required but it's not installed. Aborting." >&2; exit 1; }

# Because I keep forgetting how this works:
# 1. flatten: jq -s reads 1 or more data structure in as an array. Flatten will ensure it's an array of objects, not an array of arrays of objects (or deeper)
# 2. Gather data for the header section of the CSV (1st row):
#    - (map(keys) | add | unique) as $cols : for each object in the input array, get the unique keys of the object to a new array, and save as a variable
# 3. Gather data for the data section of the CSV (every other row):
#    - map(. as $row | $cols | map($row[.])) : for each object in the input array, do the following:
#      - . as $row : save the current object (row) as the variable $row
#      - $cols | map($row[.]) : for each key in $cols, output the value of the object corresponding to the key
#    - as $rows : assign the array of arrays of values to the variable $rows
# 4. $cols , $rows[]
#    - $cols : output the keys as the first row of the CSV
#    - $rows[] : output each array of values as a row of the CSV
# 5. (in command below) "${JQ_FILTER} | ${FORMAT:-@csv}" : convert the array of values to either a CSV or TSV row

# The following intentionally doesn't expand variables
# shellcheck disable=SC2016
JQ_FILTER='flatten | (map(keys) | add | unique) as $cols | map(. as $row | $cols | map($row[.])) as $rows | $cols , $rows[]'

jq -r -s "${JQ_FILTER} | ${FORMAT:-@csv}"  "${INPUT:-/dev/stdin}"
