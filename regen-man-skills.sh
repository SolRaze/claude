#!/usr/bin/env bash
# Regenerate man-page-backed reference skills for locally installed tools.
# Source of truth is the man pages of the *installed* binaries, so these
# skills always match the versions on this machine. Re-run after upgrades.
set -euo pipefail

SKILLS="${SKILLS_DIR:-$HOME/.claude/skills}"

# man -> plain text. col -b strips the backspace overstrike bold/underline.
render() { man "$1" 2>/dev/null | col -b; }

# ref <skill> <file> <title> <man-arg>
ref() {
  local skill=$1 file=$2 title=$3 page=$4
  local dir="$SKILLS/$skill/references"
  mkdir -p "$dir"
  { printf '# %s\n\n' "$title"; render "$page"; } > "$dir/$file"
  local w; w=$(wc -w < "$dir/$file" | tr -d ' ')
  if [ "$w" -lt 50 ]; then echo "  !! $skill/$file: only $w words - check '$page'"; else
    echo "  ok $skill/$file ($w words)"; fi
}

skill_md() { mkdir -p "$SKILLS/$1"; cat > "$SKILLS/$1/SKILL.md"; }

echo "==> tmux"
ref tmux tmux.md "tmux manual" tmux
skill_md tmux <<'EOF'
---
name: tmux
description: Reference for tmux - sessions, windows, panes, key bindings, copy-mode, status line, and .tmux.conf options. Use when writing or debugging tmux config, key bindings, status-left/status-right formats, or tmux CLI commands.
disable-model-invocation: true
effort: low
---

# tmux

Complete tmux manual for the locally installed version.

## When to use

- Writing or debugging `.tmux.conf`
- Looking up `set-option` / `setw` option names and defaults
- `bind-key` syntax and key table semantics
- `status-left` / `status-right` format strings and `#{...}` replacements
- copy-mode keys and selection commands
- Any `tmux` subcommand's flags

## Reference

- `references/tmux.md` - the complete tmux(1) manual, verbatim.

Grep it rather than reading whole. Useful anchors: `FORMATS`, `OPTIONS`,
`KEY BINDINGS`, `WINDOWS AND PANES`, `STATUS LINE`.
EOF

echo "==> ghostty"
ref ghostty cli.md "ghostty(1) - CLI" ghostty
ref ghostty config.md "ghostty(5) - configuration" /opt/homebrew/share/man/man5/ghostty.5
skill_md ghostty <<'EOF'
---
name: ghostty
description: Reference for the Ghostty terminal emulator - every config key, keybind action, theme and font option, plus CLI flags and actions. Use when editing Ghostty config, setting keybinds, themes, fonts, or shaders.
disable-model-invocation: true
effort: low
---

# Ghostty

Complete Ghostty CLI and configuration reference for the locally installed version.

## When to use

- Editing `~/.config/ghostty/config`
- Looking up a config key's exact name, type, and default
- `keybind` syntax and the full list of bindable actions
- Font, theme, colour, and shader options
- `ghostty +<action>` CLI actions

## References

- `references/config.md` - ghostty(5), every config key. Start here for config work.
- `references/cli.md` - ghostty(1), CLI flags and actions.

Grep by key name; the config reference is long.
EOF

echo "==> sketchybar"
ref sketchybar cli.md "sketchybar(1) - CLI" sketchybar
ref sketchybar config.md "sketchybar(5) - configuration" /opt/homebrew/share/man/man5/sketchybar.5
for t in items events components popup query types animate tips; do
  ref sketchybar "$t.md" "sketchybar-$t(5)" "/opt/homebrew/share/man/man5/sketchybar-$t.5"
done
skill_md sketchybar <<'EOF'
---
name: sketchybar
description: Reference for SketchyBar on macOS - items, events, components, popups, queries, property types, and animation. Use when writing sketchybarrc, adding bar items, wiring custom events, or scripting plugins.
disable-model-invocation: true
effort: low
---

# SketchyBar

Complete SketchyBar reference for the locally installed version.

## When to use

- Writing `sketchybarrc` or item plugin scripts
- Looking up an item property's exact name and type
- Subscribing to events (including custom `--trigger` events)
- Building popups, graphs, sliders, brackets
- Querying bar/item state as JSON

## References

- `references/items.md` - item properties. The main one for config work.
- `references/events.md` - built-in and custom events, `--subscribe` / `--trigger`.
- `references/components.md` - graphs, sliders, brackets, aliases.
- `references/popup.md` - popup menus.
- `references/query.md` - `--query` JSON output.
- `references/types.md` - property value types.
- `references/animate.md` - animation curves and `--animate`.
- `references/tips.md` - assorted usage tips.
- `references/cli.md` / `references/config.md` - sketchybar(1) and sketchybar(5).

Note: this repo's Stop hook fires `sketchybar --trigger claude_refresh`;
see `references/events.md` for custom event semantics.
EOF

echo "==> aerospace"
# The cask does not link its man pages into share/man; read them beside the binary.
AERO_MAN="$(dirname "$(dirname "$(readlink -f "$(command -v aerospace)")")")/manpage"
{
  printf '# AeroSpace commands\n\n'
  printf 'All aerospace(1) subcommand man pages, concatenated.\n\n'
  render "$AERO_MAN/aerospace.1"
  for f in "$AERO_MAN"/aerospace-*.1; do
    n=$(basename "$f" .1)
    printf '\n\n---\n\n## %s\n\n' "$n"
    render "$f"
  done
} > /tmp/aerospace-cli.md
mkdir -p "$SKILLS/aerospace/references"
mv /tmp/aerospace-cli.md "$SKILLS/aerospace/references/commands.md"
echo "  ok aerospace/commands.md ($(wc -w < "$SKILLS/aerospace/references/commands.md" | tr -d ' ') words)"
skill_md aerospace <<'EOF'
---
name: aerospace
description: Reference for AeroSpace, the macOS tiling window manager - every CLI subcommand, its flags, and semantics. Use when writing aerospace.toml bindings, scripting workspace/window commands, or debugging aerospace behaviour.
disable-model-invocation: true
effort: low
---

# AeroSpace

All AeroSpace subcommand manuals for the locally installed version.

## When to use

- Writing `aerospace.toml` binding commands
- Looking up a subcommand's exact flags (`focus`, `move`, `workspace`,
  `move-node-to-workspace`, `layout`, `mode`, ...)
- Scripting against `list-windows` / `list-apps` / `query` output
- `on-window-detected` / callback and mode semantics

## Reference

- `references/commands.md` - aerospace(1) plus all 46 subcommand pages.
  Grep for the subcommand name; each is a `## aerospace-<name>` section.
- `references/config.md` - the `aerospace.toml` config file format from the
  project site: `[mode.main.binding]`, `on-window-detected`, gaps, callbacks,
  `after-startup-command`, layouts and monitor assignment.

## Sources

`commands.md` comes from the local man pages, so it is version-matched to the
installed binary. `config.md` comes from the project website
(https://nikitabobko.github.io/AeroSpace/guide), which tracks the latest
release and may drift from the installed version.
EOF

echo "==> zsh"
for p in zshroadmap zshmisc zshbuiltins zshoptions zshparam zshexpn zshzle zshcompsys zshcompwid zshcontrib zshmodules; do
  ref zsh "$p.md" "$p(1)" "$p"
done
skill_md zsh <<'EOF'
---
name: zsh
description: Reference for zsh - builtins, options (setopt), parameters, expansion, ZLE line editor, completion system, and contributed functions. Use when writing .zshrc, prompts, completions, ZLE widgets, or debugging zsh expansion and globbing.
disable-model-invocation: true
effort: low
---

# zsh

The complete zsh manual set for the locally installed version, split by topic.

## When to use

- Writing `.zshrc`, prompts, or functions
- `setopt` option names and defaults
- Parameter expansion, globbing, and expansion flags
- ZLE widgets and keybinds (`bindkey`)
- The completion system (`compdef`, `_arguments`, ...)

## References — pick by topic, do not read all

- `references/zshroadmap.md` - start here; maps topics to pages.
- `references/zshoptions.md` - every `setopt` option.
- `references/zshbuiltins.md` - every builtin command.
- `references/zshparam.md` - parameters and special variables.
- `references/zshexpn.md` - expansion, globbing, expansion flags.
- `references/zshmisc.md` - syntax, prompt escapes, redirection, functions.
- `references/zshzle.md` - line editor, `bindkey`, widgets.
- `references/zshcompsys.md` - completion system.
- `references/zshcompwid.md` - completion widgets (low-level).
- `references/zshcontrib.md` - contributed functions (vcs_info, zmv, ...).
- `references/zshmodules.md` - loadable modules (zsh/zpty, zsh/net, ...).

These are large. Grep for the option or builtin name; do not read a whole file.
EOF

echo
echo "Done. Skills in $SKILLS:"
for s in tmux ghostty sketchybar aerospace zsh; do
  printf '  %-11s %s words across %s refs\n' "$s" \
    "$(cat "$SKILLS/$s"/references/*.md | wc -w | tr -d ' ')" \
    "$(find "$SKILLS/$s/references" -type f | wc -l | tr -d ' ')"
done
