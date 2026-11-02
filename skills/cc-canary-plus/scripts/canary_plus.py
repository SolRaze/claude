#!/usr/bin/env python3
"""cc-canary-plus — three drift signals cc-canary does not compute.

Companion to delta-hq/cc-canary. Same inputs (~/.claude/projects/**/*.jsonl),
same dedupe rule ((message.id, requestId)), same constraints: pure stdlib,
read-only, no network.

  A  cohort split      is it the model, or the harness / effort level?
  B  instruction decay how fast do this user's CLAUDE.md rules stop being obeyed?
  C  stylometry        did the prose fingerprint step-change (silent swap)?

Why not inference_geo/service_tier/speed (the obvious cohort keys): on this
account they are 100% not_available/standard/standard. Measured, not assumed.
Cohorting uses effort x model x cc-version, which do vary.
"""
from __future__ import annotations

import argparse
import glob
import json
import math
import os
import re
import statistics
import sys
from collections import Counter, defaultdict
from datetime import datetime, timedelta, timezone

# ---------------------------------------------------------------- B: the rules
# Only rules that are mechanically checkable from a tool_use record. A rule that
# needs judgement is not a metric.
BASH_LIMITERS = ("head", "tail", "| rg", "|rg", "grep -c", "wc -l", "--max-count",
                 "-n 1", "| jq", "| awk", "| sort", "| uniq", "| cut", "| sed -n")
ATTRIBUTION = re.compile(r"co-authored-by:\s*claude|generated with \[?claude code|🤖 generated", re.IGNORECASE)
# Scanned in tool INPUTS only (a commit being authored, a file being written) —
# never in assistant prose. Prose matches are almost all the opposite of a
# violation: reports about scrubbing attribution. Measured: 7/7 prose hits were
# compliance write-ups, 0 were emissions.
BIG_READ_BYTES = 40_000          # a Read result this large should have been paged
BIG_BASH_BYTES = 10_000          # a Bash result this large should have been piped

# ---------------------------------------------------------------- C: stylometry
FUNCTION_WORDS = ("the", "of", "and", "to", "a", "in", "that", "is", "it",
                  "for", "as", "with", "on", "but", "not", "this", "so")
HEDGES = ("might", "perhaps", "possibly", "generally", "typically", "somewhat",
          "arguably", "roughly", "fairly", "seems", "appears", "likely")
SENT_SPLIT = re.compile(r"[.!?]+[\s\n]")
WORD = re.compile(r"[a-z']+")


def iter_requests(projects_dir: str, cutoff: datetime, exclude: list[str]):
    """Yield deduped assistant records with usage, newest-first-safe."""
    files = sorted(glob.glob(os.path.join(projects_dir, "**", "*.jsonl"), recursive=True))
    if exclude:
        files = [f for f in files
                 if not any(p in os.path.basename(os.path.dirname(f)) for p in exclude)]
    seen: set[tuple] = set()
    for path in files:
        try:
            if datetime.fromtimestamp(os.path.getmtime(path), tz=timezone.utc) < cutoff:  # noqa: UP017 - runs on python3 3.9
                continue
        except OSError:
            continue
        try:
            with open(path, errors="ignore") as fh:
                for line in fh:
                    try:
                        d = json.loads(line)
                    except ValueError:
                        continue
                    yield path, d, seen
        except OSError:
            continue


def week_of(ts: str) -> str:
    try:
        dt = datetime.fromisoformat(ts.replace("Z", "+00:00"))  # noqa: FURB162 - runs on python3 3.9
    except (TypeError, ValueError):
        return "?"
    return (dt - timedelta(days=dt.weekday())).strftime("%Y-%m-%d")


def cosine(a: dict, b: dict) -> float:
    keys = set(a) | set(b)
    num = sum(a.get(k, 0.0) * b.get(k, 0.0) for k in keys)
    na = math.sqrt(sum(v * v for v in a.values()))
    nb = math.sqrt(sum(v * v for v in b.values()))
    return num / (na * nb) if na and nb else 0.0


def text_of(content) -> str:
    if isinstance(content, str):
        return content
    out = []
    if isinstance(content, list):
        for blk in content:
            if isinstance(blk, dict) and blk.get("type") == "text":
                out.append(blk.get("text") or "")
    return "\n".join(out)


def main() -> int:
    ap = argparse.ArgumentParser(description="cc-canary-plus: cohort, instruction-decay and stylometry signals")
    ap.add_argument("--window", default="60d")
    ap.add_argument("--projects-dir", default=os.path.expanduser("~/.claude/projects"))
    ap.add_argument("--exclude-project", action="append", default=[], metavar="SUBSTR",
                    help="skip projects whose slug contains SUBSTR (repeatable)")
    ap.add_argument("--json", action="store_true", help="emit raw JSON instead of a report")
    args = ap.parse_args()

    m = re.fullmatch(r"(\d+)d", args.window)
    if not m:
        print(f"bad window: {args.window}", file=sys.stderr)
        return 2
    cutoff = datetime.now(timezone.utc) - timedelta(days=int(m.group(1)))  # noqa: UP017 - runs on python3 3.9

    # --- accumulators -------------------------------------------------------
    cohort = defaultdict(lambda: Counter())          # (effort,model,ver) -> counters
    weekly_tokens = defaultdict(Counter)
    viol = defaultdict(Counter)                      # week -> rule -> n
    toolcalls = Counter()                            # week -> n
    style_txt = defaultdict(list)                    # week -> [text]
    tool_seq = defaultdict(Counter)                  # week -> tool -> n
    seen: set[tuple] = set()
    pending_read: dict[str, bool] = {}               # tool_use_id -> had_paging
    pending_bash: dict[str, bool] = {}               # tool_use_id -> had_limiter

    for _path, d, _s in iter_requests(args.projects_dir, cutoff, args.exclude_project):
        t = d.get("type")
        ts = d.get("timestamp") or ""
        wk = week_of(ts)

        # ---- tool_result sizes, to grade the Read rule ----------------------
        if t == "user":
            c = (d.get("message") or {}).get("content")
            if isinstance(c, list):
                for blk in c:
                    if isinstance(blk, dict) and blk.get("type") == "tool_result":
                        tid = blk.get("tool_use_id")
                        if tid in pending_read or tid in pending_bash:
                            body = blk.get("content")
                            size = len(json.dumps(body)) if not isinstance(body, str) else len(body)
                            if tid in pending_read:
                                if size > BIG_READ_BYTES and not pending_read[tid]:
                                    viol[wk]["read_no_paging"] += 1
                                pending_read.pop(tid, None)
                            else:
                                if size > BIG_BASH_BYTES and not pending_bash[tid]:
                                    viol[wk]["bash_unbounded"] += 1
                                pending_bash.pop(tid, None)
            continue

        if t != "assistant":
            continue
        msg = d.get("message") or {}
        key = (msg.get("id"), d.get("requestId"))
        if key in seen:
            continue
        seen.add(key)

        usage = msg.get("usage") or {}
        model = msg.get("model") or "?"
        ck = (str(d.get("effort")), model, d.get("version") or "?")
        cohort[ck]["requests"] += 1
        cohort[ck]["out_tok"] += usage.get("output_tokens") or 0
        cohort[ck]["cache_read"] += usage.get("cache_read_input_tokens") or 0
        if msg.get("stop_reason") not in (None, "end_turn", "tool_use"):
            cohort[ck]["odd_stop"] += 1

        weekly_tokens[wk]["out"] += usage.get("output_tokens") or 0
        weekly_tokens[wk]["req"] += 1

        content = msg.get("content")
        blocks = content if isinstance(content, list) else []
        tools = [b for b in blocks if isinstance(b, dict) and b.get("type") == "tool_use"]
        for b in tools:
            name = b.get("name") or "?"
            inp = b.get("input") or {}
            toolcalls[wk] += 1
            tool_seq[wk][name] += 1
            # --- rule: pipe Bash through a limiter --------------------------
            # Judged on the RESULT, not the command: `mkdir -p x` needs no head.
            # Only a large result proves the limiter was actually needed.
            if name == "Bash":
                cmd = str(inp.get("command") or "")
                pending_bash[b.get("id") or ""] = any(l in cmd for l in BASH_LIMITERS)
                if ATTRIBUTION.search(cmd) and "git commit" in cmd:
                    viol[wk]["ai_attribution"] += 1
            # --- rule: page big Reads ---------------------------------------
            if name == "Read":
                pending_read[b.get("id") or ""] = bool(inp.get("offset") or inp.get("limit"))
            # --- rule: never write attribution into a file ------------------
            # CLAUDE.md and the memory stores quote the banned trailer in order
            # to ban it. Writing the rule is not breaking the rule.
            if name in ("Write", "Edit"):
                fp_ = str(inp.get("file_path") or "")
                documents_the_rule = (
                    fp_.endswith(("CLAUDE.md", "memory.md"))
                    or "/.claude/projects/" in fp_
                )
                body = str(inp.get("content") or "") + str(inp.get("new_string") or "")
                if ATTRIBUTION.search(body) and not documents_the_rule:
                    viol[wk]["ai_attribution"] += 1

        # --- rule: never emit AI attribution --------------------------------
        txt = text_of(content)
        if txt:
            style_txt[wk].append(txt)

    # --- C: per-week style vectors -----------------------------------------
    style = {}
    for wk, chunks in style_txt.items():
        blob = "\n".join(chunks)
        if len(blob) < 4000:
            continue
        low = blob.lower()
        words = WORD.findall(low)
        if len(words) < 800:
            continue
        sents = [s for s in SENT_SPLIT.split(blob) if s.strip()]
        lens = [len(WORD.findall(s.lower())) for s in sents] or [0]
        n = len(words)
        vec = {f"fw_{w}": words.count(w) / n for w in FUNCTION_WORDS}
        vec["hedge"] = sum(words.count(h) for h in HEDGES) / n
        vec["emdash"] = blob.count("—") / max(len(blob) / 1000, 1)
        vec["ttr"] = len(set(words)) / n
        vec["sent_mean"] = statistics.mean(lens) / 40
        vec["sent_var"] = (statistics.pstdev(lens) / 20) if len(lens) > 1 else 0.0
        style[wk] = vec

    out = {
        "window": args.window,
        "cohorts": {
            " | ".join(k): dict(v) for k, v in
            sorted(cohort.items(), key=lambda kv: -kv[1]["requests"])
        },
        "weeks": sorted(set(list(viol) + list(toolcalls) + list(style))),
        "violations": {w: dict(v) for w, v in sorted(viol.items())},
        "tool_calls": dict(sorted(toolcalls.items())),
        "style": style,
    }
    if args.json:
        print(json.dumps(out, indent=2))
        return 0

    # ------------------------------------------------------------- report ---
    P = print
    P(f"\ncc-canary-plus — window {args.window}\n" + "=" * 62)

    P("\nA. COHORTS  (is it the model, or the harness?)\n")
    P(f"  {'effort | model | cc-version':<44}{'reqs':>7}{'out/req':>9}{'odd':>5}")
    for k, v in list(out["cohorts"].items())[:10]:
        r = v["requests"]
        P(f"  {k:<44}{r:>7}{v['out_tok']//max(r,1):>9}{v.get('odd_stop',0):>5}")
    P("\n  Same model on two cc-versions with different out/req = harness change,")
    P("  not model drift. Same version, two models = a real comparison.")

    P("\nB. INSTRUCTION DECAY  (violations per 100 tool calls)\n")
    P(f"  {'week':<12}{'calls':>7}{'bash':>7}{'read':>7}{'attr':>7}{'per100':>9}")
    for w in sorted(toolcalls):
        c = toolcalls[w]
        vb, vr, va = viol[w]["bash_unbounded"], viol[w]["read_no_paging"], viol[w]["ai_attribution"]
        tot = vb + vr + va
        P(f"  {w:<12}{c:>7}{vb:>7}{vr:>7}{va:>7}{100*tot/max(c,1):>9.1f}")
    P("\n  bash = Bash whose result exceeded 10KB with no head/rg/limiter in the command")
    P("  read = Read result over 40KB with no offset/limit")
    P("  attr = attribution written into a commit or a file (should be 0, always)")

    P("\nC. STYLOMETRY  (cosine vs previous week; a step = possible silent swap)\n")
    wks = sorted(style)
    if len(wks) < 2:
        P("  not enough text-bearing weeks in this window.")
    else:
        P(f"  {'week':<12}{'cos(prev)':>11}{'sent_mean':>11}{'sent_var':>10}{'hedge/1k':>10}")
        prev = None
        for w in wks:
            c = f"{cosine(style[w], style[prev]):.4f}" if prev else "     —"
            v = style[w]
            P(f"  {w:<12}{c:>11}{v['sent_mean']*40:>11.1f}{v['sent_var']*20:>10.1f}{v['hedge']*1000:>10.2f}")
            prev = w
        P("\n  Falling sent_var with flat sent_mean is the classic quantization tell:")
        P("  uniform sentence lengths. A cosine dip with no model change in A is the")
        P("  thing to escalate.")
    P("")
    return 0


if __name__ == "__main__":
    sys.exit(main())
