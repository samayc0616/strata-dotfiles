#!/bin/bash

# Monokai Pro palette
G=$'\033[38;2;169;220;118m'   # green
P=$'\033[38;2;255;97;136m'    # pink
Y=$'\033[38;2;255;216;102m'   # yellow
B=$'\033[38;2;120;220;232m'   # blue
V=$'\033[38;2;171;157;242m'   # violet
O=$'\033[38;2;252;169;104m'   # orange
A=$'\033[38;2;114;112;114m'   # gray
W=$'\033[38;2;252;252;250m'   # white
BOLD=$'\033[1m'
DIM=$'\033[2m'
R=$'\033[0m'

DASH70="──────────────────────────────────────────────────────────────────────"

# row  lcolor lkey ldesc  rcolor rkey rdesc
row() {
    printf "   ${1}%-5s${R}  %-30s    ${4}%-9s${R}  %s\n" \
        "$2" "$3" "$5" "$6"
}

# section  lcolor ltitle  rcolor rtitle
section() {
    local lt="$2" rt="$4"
    local lpad=$((41 - ${#lt}))
    local lund="" rund="" i
    for ((i=0; i<${#lt}; i++)); do lund+="─"; done
    for ((i=0; i<${#rt}; i++)); do rund+="─"; done
    printf "   ${1}${BOLD}%s${R}%${lpad}s${3}${BOLD}%s${R}\n" "$lt" "" "$rt"
    printf "   ${1}%s${R}%${lpad}s${3}%s${R}\n"               "$lund" "" "$rund"
}

echo ""
printf "   ${BOLD}${W}TMUX · KEYBINDINGS${R}%35s${DIM}prefix:${R} ${Y}C-a${R} ${A}·${R} ${Y}C-b${R}\n" ""
printf "   ${A}${DASH70}${R}\n"
echo ""

section "$P" "PREFIX"                          "$B" "NO PREFIX"
row "$Y" "?"    "help"                         "$O" "C-hjkl"    "navigate panes"
row "$Y" "r"    "reload config"                "$O" "M-hjkl"    "window/session nav"
row "$Y" "d"    "detach"                       "$O" "M-1..9"    "select window"
row "$Y" "m"    "toggle mouse"                 "$O" "M-←/→"     "word back / fwd"
row "$Y" "S"    "sync panes"                   "$O" "M-c/n"     "copy · notify"
row "$Y" "C-l"  "clear history"                "$O" "M-HJKL"    "resize pane"
echo ""

section "$Y" "WINDOWS"                         "$G" "PANES"
row "$Y" "c"    "new window"                   "$G" "\" %"      "split h / v"
row "$Y" ","    "rename"                       "$G" "- _"       "split h / v"
row "$Y" "."    "move"                         "$G" "x  X"      "kill pane / window"
row "$Y" "> <"  "swap right / left"            "$G" "z"         "zoom toggle"
row "$Y" "Tab"  "last window"                  "$G" "Space"     "cycle layouts"
row ""   ""     ""                             "$G" "C-o/M-o"   "rotate fwd / back"
row ""   ""     ""                             "$G" "=  |"      "balance h / v"
echo ""

section "$V" "SESSIONS"                        "$O" "COPY MODE"
row "$Y" "s"    "list"                         "$V" "v"         "begin selection"
row "$Y" "\$"   "rename"                       "$V" "C-v"       "rectangle toggle"
row "$Y" "( )"  "prev / next"                  "$V" "y"         "copy & exit"
row "$Y" "C-c"  "new session"                  "$V" "Esc"       "cancel"
row "$Y" "C-f"  "find session"                 ""   ""          ""
echo ""

printf "   ${A}${DASH70}${R}\n"
printf "                        ${DIM}press any key to close${R}\n"
