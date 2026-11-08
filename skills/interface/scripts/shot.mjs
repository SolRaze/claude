// node shot.mjs <url> <out.png> <w> <h> [steps...]  headless Helium over CDP, one run drives a whole sequence
// steps: a KeyboardEvent key (ArrowDown, Escape, ']') | wait<ms> | js:<expr> prints its value | snap:<file.png> mid-run
// out.png is taken after the last step. Background throttling is off, so rAF runs; T3 preview tabs pause it.
import { spawn, execSync } from 'node:child_process';
import { writeFileSync } from 'node:fs';
try { execSync("pkill -f 'user-data-dir=/tmp/shot/profile'"); await new Promise((r) => setTimeout(r, 500)); } catch {}
const [url, out, W, H, ...keys] = process.argv.slice(2);
const bin = process.env.SHOT_BROWSER || '/Applications/Helium.app/Contents/MacOS/Helium';
const p = spawn(bin, ['--headless=new', '--remote-debugging-port=9333', '--user-data-dir=/tmp/shot/profile',
  '--ignore-certificate-errors', '--disable-background-timer-throttling', '--disable-renderer-backgrounding', '--disable-backgrounding-occluded-windows', `--window-size=${W},${H}`, 'about:blank'], { stdio: 'ignore' });
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
let tabs;
for (let i = 0; i < 50; i++) { try { tabs = await (await fetch('http://127.0.0.1:9333/json')).json(); break; } catch { await sleep(200); } }
const ws = new WebSocket(tabs.find((t) => t.type === 'page').webSocketDebuggerUrl);
await new Promise((r) => ws.addEventListener('open', r));
let id = 0; const wait = {};
ws.addEventListener('message', (m) => { const d = JSON.parse(m.data); if (wait[d.id]) { wait[d.id](d.result); delete wait[d.id]; } });
const cmd = (method, params = {}) => new Promise((r) => { wait[++id] = r; ws.send(JSON.stringify({ id, method, params })); });
await cmd('Emulation.setDeviceMetricsOverride', { width: +W, height: +H, deviceScaleFactor: 1, mobile: +W < 761 });
await cmd('Page.bringToFront'); await cmd('Page.navigate', { url });
await sleep(3000);
const snap = async (f) => { const { data } = await cmd('Page.captureScreenshot', { format: 'png' }); writeFileSync(f, Buffer.from(data, 'base64')); console.log(f); };
for (const k of keys) {
  if (k.startsWith('wait')) { await sleep(+k.slice(4)); continue; }
  if (k.startsWith('snap:')) { await sleep(600); await snap(k.slice(5)); continue; }
  if (k.startsWith('js:')) { console.log(JSON.stringify((await cmd('Runtime.evaluate', { expression: k.slice(3), awaitPromise: true, returnByValue: true })).result.value)); continue; }
  await cmd('Runtime.evaluate', { expression: `document.dispatchEvent(new KeyboardEvent('keydown',{key:${JSON.stringify(k)},bubbles:true}))` });
  await sleep(250);
}
await sleep(900);
await snap(out);
ws.close(); p.kill();
