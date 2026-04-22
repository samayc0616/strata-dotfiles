#!/usr/bin/env bash
# Claude Code status line — Monokai truecolor, single-line, fast
# All jq fields extracted in one pass to minimise subprocess overhead.

input=$(cat)

# --- Extract each field with its own jq call to avoid IFS/splitting issues ---
model_raw=$(printf '%s' "$input" | jq -r '.model.display_name // empty')
cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')
used_pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
five_h_pct=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_h_reset=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_d_pct=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
seven_d_reset=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
total_cost=$(printf '%s' "$input" | jq -r '.cost.total_cost_usd // empty')
lines_added=$(printf '%s' "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(printf '%s' "$input" | jq -r '.cost.total_lines_removed // 0')

# --- Monokai Pro (default filter) truecolor palette ---
RESET=$'\033[0m'
BOLD=$'\033[1m'
PINK=$'\033[38;2;255;97;136m'       # #FF6188
BLUE=$'\033[38;2;120;220;232m'      # #78DCE8
YELLOW=$'\033[38;2;255;216;102m'    # #FFD866
GREEN=$'\033[38;2;169;220;118m'     # #A9DC76
ORANGE=$'\033[38;2;252;152;103m'    # #FC9867
PURPLE=$'\033[38;2;171;157;242m'    # #AB9DF2
GREY=$'\033[2;38;2;114;112;114m'    # #727072 dim

SEP="${GREY} │ ${RESET}"

# --- Helper: append a segment ---
parts=()
add() { parts+=("$1"); }

# --- Helper: format seconds-from-now into "Xd Yh" / "Xh Ym" / "Ym" / "now" ---
fmt_relative() {
  local target=$1
  [ -z "$target" ] || [ "$target" = "null" ] && return 1
  local now delta d h m
  now=$(date +%s)
  delta=$(( target - now ))
  if [ "$delta" -le 0 ]; then printf 'now'; return 0; fi
  if [ "$delta" -ge 86400 ]; then
    d=$(( delta / 86400 )); h=$(( (delta % 86400) / 3600 ))
    printf '%dd %dh' "$d" "$h"
  elif [ "$delta" -ge 3600 ]; then
    h=$(( delta / 3600 )); m=$(( (delta % 3600) / 60 ))
    printf '%dh %dm' "$h" "$m"
  else
    m=$(( (delta + 59) / 60 ))
    printf '%dm' "$m"
  fi
}

# 1. Model — strip leading "Claude ", bold pink
if [ -n "$model_raw" ]; then
  short_model="${model_raw#Claude }"
  add "${BOLD}${PINK}${short_model}${RESET}"
fi

# 2. Directory — cyan full path, bold leaf (mirrors p10k: ANCHOR_BOLD on last segment only)
if [ -n "$cwd" ]; then
  home_escaped="${HOME%/}"
  dir="${cwd/#$home_escaped/\~}"
  if [[ "$dir" == */* ]]; then
    leaf="${dir##*/}"
    head="${dir%/*}/"
    add "${BLUE}${head}${BOLD}${leaf}${RESET}"
  else
    add "${BOLD}${BLUE}${dir}${RESET}"
  fi
fi

# 3. Git branch — yellow, Nerd Font glyph  (U+E0A0)
if [ -n "$cwd" ]; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    add "${YELLOW} ${branch}${RESET}"
  fi
fi

# 4. Context % — color-coded by threshold; hide if absent
if [ -n "$used_pct" ] && [ "$used_pct" != "null" ]; then
  pct_int=$(printf '%.0f' "$used_pct")
  if   [ "$pct_int" -ge 95 ]; then CTX_COLOR="$PINK"
  elif [ "$pct_int" -ge 80 ]; then CTX_COLOR="$ORANGE"
  elif [ "$pct_int" -ge 50 ]; then CTX_COLOR="$YELLOW"
  else                              CTX_COLOR="$GREEN"
  fi
  add "${CTX_COLOR}ctx ${pct_int}%${RESET}"
fi

# 5. 5-hour rate limit — purple; append "· in Xh Ym" if reset known
if [ -n "$five_h_pct" ] && [ "$five_h_pct" != "null" ]; then
  fh_int=$(printf '%.0f' "$five_h_pct")
  fh_rel=$(fmt_relative "$five_h_reset")
  if [ -n "$fh_rel" ]; then
    add "${PURPLE}5h ${fh_int}% · in ${fh_rel}${RESET}"
  else
    add "${PURPLE}5h ${fh_int}%${RESET}"
  fi
fi

# 5b. 7-day rate limit — pink, no countdown
if [ -n "$seven_d_pct" ] && [ "$seven_d_pct" != "null" ]; then
  sd_int=$(printf '%.0f' "$seven_d_pct")
  add "${PINK}7d ${sd_int}%${RESET}"
fi

# 6. Session cost — orange bold, hide if 0 or absent
if [ -n "$total_cost" ] && [ "$total_cost" != "null" ] && [ "$total_cost" != "0" ]; then
  cost_fmt=$(printf '%.2f' "$total_cost" 2>/dev/null)
  if [ -n "$cost_fmt" ] && [ "$cost_fmt" != "0.00" ]; then
    add "${BOLD}${ORANGE}\$${cost_fmt}${RESET}"
  fi
fi

# 7. Diff stats — hide if both zero
lines_added="${lines_added:-0}"
lines_removed="${lines_removed:-0}"
if [ "$lines_added" != "0" ] || [ "$lines_removed" != "0" ]; then
  add "${GREEN}+${lines_added}${RESET} ${PINK}-${lines_removed}${RESET}"
fi

# --- Join with separator and print ---
if [ ${#parts[@]} -eq 0 ]; then
  printf ''
  exit 0
fi

out="${parts[0]}"
for (( i=1; i<${#parts[@]}; i++ )); do
  out="${out}${SEP}${parts[$i]}"
done

printf '%b' "$out"
