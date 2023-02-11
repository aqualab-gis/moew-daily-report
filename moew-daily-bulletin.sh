#!/bin/bash

set -x

OUT="$(mktemp)"

ruby acquire.rb > "$OUT"

wget -P reports -nc -i "$OUT"

rm "$OUT"

ruby acquire.rb > parsed_data/missing_reports.txt

for file in reports/*.pdf; do
    output_file=`basename "$file" .pdf`.txt

    if [ ! -f "parsed_data/text/$output_file" ]; then
       pdftotext -layout "$file"
       mv "reports/$output_file" parsed_data/text/
    fi
done

ruby parse.rb 2> parsed_data/parse_errors.txt
