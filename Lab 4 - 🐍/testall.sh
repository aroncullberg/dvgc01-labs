#*********************************
# Aron Cullberg    -   aroncull100                                    
# Viktor Hajto     -   vikthajt100                                    
#*********************************

#Linux system kan stötta på problem, vi har endast testat på windows/WSL

#!/bin/sh
for i in TestSuite/*.pas; do
    [ -f "$i" ] || continue
    echo "testing $i"
    python3 parser.py < "$i"
done