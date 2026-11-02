#!/usr/bin/env node
// UserPromptSubmit hook: appends long user prompts verbatim to <project>/Inbox/raw-prompt.md.
//
// Opt-in per project: does nothing unless an `Inbox/` directory exists at or above cwd.
// Silent by design — anything printed on stdout would be injected into the model's context.
// Never throws: a broken log must not block a prompt.

const fs = require('fs');
const path = require('path');

const MIN_CHARS = 80; // "continue" / "bro it working?" are not commanding prompts
const HEADER = `# Prompt log

Every commanding prompt verbatim, newest last. Written by the prompt-log hook
(~/.claude/hooks/prompt-log.js). Prompts under ${MIN_CHARS} chars and slash commands are skipped.
`;

let raw = '';
process.stdin.on('data', (d) => (raw += d));
process.stdin.on('end', () => {
  try {
    run(JSON.parse(raw || '{}'));
  } catch {
    // swallow: logging is best-effort
  }
  process.exit(0);
});

function findInbox(start) {
  let dir = start;
  for (let i = 0; i < 8 && dir && dir !== path.parse(dir).root; i++) {
    const candidate = path.join(dir, 'Inbox');
    try {
      if (fs.statSync(candidate).isDirectory()) return candidate;
    } catch {}
    dir = path.dirname(dir);
  }
  return null;
}

function run(payload) {
  const prompt = (payload.prompt || '').trim();
  if (prompt.length < MIN_CHARS) return;
  if (prompt.startsWith('/')) return; // slash command, not an ask

  const inbox = findInbox(payload.cwd || process.cwd());
  if (!inbox) return; // project hasn't opted in

  const file = path.join(inbox, 'raw-prompt.md');
  if (!fs.existsSync(file)) fs.writeFileSync(file, HEADER);

  const prev = fs.readFileSync(file, 'utf8');
  const body = prompt
    .split('\n')
    .map((l) => '> ' + l)
    .join('\n');
  if (prev.includes(body)) return; // resubmit / retry of the same prompt

  const now = new Date(); // local date, not UTC — a 1am prompt belongs to today's heading
  const day = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}`;
  const head = prev.includes(`\n## ${day}\n`) ? '' : `\n## ${day}\n`;
  fs.appendFileSync(file, `${prev.endsWith('\n') ? '' : '\n'}${head}\n${body}\n`);
}
