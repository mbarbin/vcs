#!/bin/bash -e

# Change the current working directory to the directory where the script is located
cd "$(dirname "$0")"

for i in `ls *.dot`; do
    echo "Processing $i ..."
    dot -Tpng $i -o `echo $i | sed 's/.dot/.png/'`
done
