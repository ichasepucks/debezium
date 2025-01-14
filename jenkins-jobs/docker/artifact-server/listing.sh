#! /usr/bin/env bash

OPTS=$(getopt -o d:o: --long dir:,output: -n 'parse-options' -- "$@")
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi
eval set -- "$OPTS"

OUTPUT="$(pwd)/artifacts.txt"
while true; do
  case "$1" in
    -d | --dir )                DIR=$2;                         shift; shift ;;
    -o | --output )             OUTPUT=$2;                      shift; shift ;;
    -h | --help )               PRINT_HELP=true;                shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

shopt -s globstar nullglob
pushd "$DIR" || exit
rm -f "$OUTPUT"
for connector in **/*connector*.{zip,jar}; do
    name=$(echo "$connector" | sed -rn 's@^(.*)-[0-9]*\..*$@\1@p')
    artifact="$name"
    echo "$artifact"
    echo "$artifact::$connector" >> "$OUTPUT"
done

scripting=$(ls **/*scripting*.{zip,jar})
artifact="debezium-scripting"
echo "$artifact"
echo "$artifact::$scripting" >> "$OUTPUT"

converter=$(ls **/*converter*.{zip,jar})
artifact="connect-converter"
echo "$artifact"
echo "$artifact::$converter" >> "$OUTPUT"

for driver in **/jdbc/*.{zip,jar}; do
    name=$(echo "$driver" | sed -rn 's@^(.*)-([[:digit:]].*([[:digit:]]|Final|SNAPSHOT))(.*)(\..*)$@\1@p')
    artifact="$name"
    echo "$artifact"
    echo "$artifact::$driver" >> "$OUTPUT"
done

popd || exit
