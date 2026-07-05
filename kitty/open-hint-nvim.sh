#!/bin/sh
# Expand leading ~ and open path from kitty hints in nvim overlay
path="$1"
if [[ "$path" == \~* ]]; then
    path="${HOME}${path#\~}"
fi
path="${path%.}"
PATH=/opt/homebrew/bin:$PATH
nvim --cmd 'nnoremap q ZQ' "$path"
