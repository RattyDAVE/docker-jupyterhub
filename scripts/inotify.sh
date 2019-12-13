#!/bin/bash

dir=/workdir
inotifywait -m -r -e create --format '%w%f' "$dir" | while read f; do
    if [[ -d "$f" ]]; then
        chmod 775 "$f"
    fi
done
