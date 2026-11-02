#!/bin/zsh
# Wipes Claude-side state for a target. Work files are never touched.
# Removal goes through /usr/bin/trash, so every burn is undoable from Finder.
set -euo pipefail

PROJECTS=~/.claude/projects
INDEX=~/Projects/memory.md
APPLY=0
KEEP_CURRENT=1
targets=()

for arg in "$@"; do
  case $arg in
    --yes)             APPLY=1 ;;
    --include-current) KEEP_CURRENT=0 ;;
    -*) print -u2 "unknown flag: $arg"; exit 2 ;;
    *)  targets+=$arg ;;
  esac
done
(( ${#targets} )) || { print -u2 "usage: burn.zsh [--yes] [--include-current] <name|path|session>"; exit 2 }

# A slug is the absolute path with every non-alphanumeric character replaced by '-'.
slug_of() { print -r -- "${1//[^a-zA-Z0-9]/-}" }

# Newest .jsonl in a store is the live session; held back unless --include-current.
current_jsonl() {
  local d=$1
  [[ -d $d ]] || return 0
  print -rl -- $d/*.jsonl(Nom[1]) 2>/dev/null
}

doomed=()

for t in $targets; do
  if [[ $t == session ]]; then
    # :A resolves symlinks — Claude Code slugs the physical path (~/.config/zsh is a stow link).
    local_slug=$(slug_of "${PWD:A}")
    store=$PROJECTS/$local_slug
    [[ -d $store ]] || { print -u2 "no store for ${PWD:A}"; continue }
    keep=$(current_jsonl "$store")
    for f in $store/*.jsonl(N); do
      [[ $KEEP_CURRENT == 1 && $f == $keep ]] && continue
      doomed+=$f
    done
  elif [[ -d $t ]]; then
    store=$PROJECTS/$(slug_of "${t:A}")
    [[ -d $store ]] && doomed+=$store || print -u2 "no store for ${t:A}"
  else
    matches=($PROJECTS/*${t}*(N/))
    (( ${#matches} )) || { print -u2 "no slug matches: $t"; continue }
    doomed+=($matches)
  fi
done

(( ${#doomed} )) || { print "nothing to burn"; exit 0 }

print "would burn:"
for d in $doomed; do print -r -- "  ${d/#$HOME/~}  ($(du -sh $d 2>/dev/null | cut -f1))"; done

# Index rows naming a burned slug become dangling pointers, so they go too.
# memory.md writes some slugs in full and some as `…<rest>` (`…` = `-Users-sol`); match both.
rows=()
if [[ -f $INDEX ]]; then
  for d in $doomed; do
    [[ -d $d ]] || continue
    s=${d:t}
    for form in $s "…${s#-Users-sol}"; do
      grep -qF -- "\`$form\`" $INDEX 2>/dev/null && rows+=$form
    done
  done
  (( ${#rows} )) && print "would strip rows from ${INDEX/#$HOME/~}: ${rows}"
fi

if (( ! APPLY )); then
  print "\ndry run. re-run with --yes to burn."
  exit 0
fi

/usr/bin/trash $doomed
for s in $rows; do
  # Table rows only — prose mentioning a slug is documentation, not a pointer.
  sed -i '' "/^|.*\`$s\`/d" $INDEX
done
print "burned ${#doomed} item(s) to Trash."
