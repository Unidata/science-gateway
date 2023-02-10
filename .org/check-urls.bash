#!/bin/bash

# Use the find command to search for all org files in the directory tree
find . -type f -name "*.org" | while read file; do
    # Use grep to extract all URLs in the file
    urls=($(grep -Eo "(http|https)://[a-zA-Z0-9./?=_-]*" $file))
    for url in "${urls[@]}"; do
        status_code=$(curl -s -o /dev/null -w "%{http_code}" "$url")
        # Check the status code
        if [[ "$status_code" -eq 200 || "$status_code" -eq 301 || "$status_code" -eq 302 || "$status_code" -eq 303 ]]; then
          echo "$url is valid."
        else
          echo "$url is not valid."
        fi
        # To avoid making it look like a DOS attack.
        sleep 2
    done
done
