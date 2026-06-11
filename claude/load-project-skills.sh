#!/usr/bin/env bash
# SessionStart hook: if .claude/SKILLS.md exists in CWD or any ancestor,
# inject its contents into the model's context.

d=$PWD
while [ "$d" != "/" ]; do
  if [ -f "$d/.claude/SKILLS.md" ]; then
    jq -Rsn \
      --rawfile content "$d/.claude/SKILLS.md" \
      --arg path "$d/.claude/SKILLS.md" \
      '{
        systemMessage: ("Loaded project skills from " + $path),
        hookSpecificOutput: {
          hookEventName: "SessionStart",
          additionalContext: ("# Project Skills (auto-loaded from " + $path + ")\n\n" + $content)
        }
      }'
    exit 0
  fi
  d=$(dirname "$d")
done
exit 0
