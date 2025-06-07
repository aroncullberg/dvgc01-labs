#!/bin/sh
for i in TestSuite/*.pas; do
    [ -f "$i" ] || continue
    echo "testing $i"
    python3 parser.py < "$i"
done