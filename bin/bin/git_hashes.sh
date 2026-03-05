#!/bin/bash

get_git_hash_prefix() {
    git rev-parse --verify --short="$2" "$1" 2>/dev/null
}

decimal_to_hex() {
    printf "%x" "$1"
}

for ref in $(git show-ref --tags | awk '/refs\/tags\/v[0-9]+\.[0-9]+\.[0-9]+/ { print $2 }'); do
    if [ $# -eq 0 ]; then
        hash_len=4
    else
        hash_len="$1"
    fi
    git_hash=$(get_git_hash_prefix "$ref" "$1")
    version="${ref#refs/tags/}"
    printf "%-15s %s\n" "$version" "$git_hash"
done


