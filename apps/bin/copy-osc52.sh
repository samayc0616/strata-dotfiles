#!/bin/bash
# OSC52 clipboard copy script for tmux
# Usage: echo "text" | copy-osc52.sh

# Read from stdin
input=$(cat)

# Check if we got input
if [ -z "$input" ]; then
    exit 0
fi

# Encode to base64 (use echo -n to avoid trailing newline)
encoded=$(echo -n "$input" | base64 | tr -d '\n')

# Send OSC52 sequence wrapped in tmux DCS passthrough
# Get the tmux client's tty
tmux_tty=$(tmux display-message -p '#{client_tty}' 2>/dev/null)

if [ -n "$tmux_tty" ] && [ -w "$tmux_tty" ]; then
    # Write directly to tmux client's tty
    printf "\033Ptmux;\033\033]52;c;%s\007\033\\" "$encoded" > "$tmux_tty"
else
    # Fallback: just output to stdout and let tmux handle it
    printf "\033Ptmux;\033\033]52;c;%s\007\033\\" "$encoded"
fi
