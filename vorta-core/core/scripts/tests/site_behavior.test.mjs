// Offline DOM/JavaScript regression checks for index.html. No network calls.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import vm from 'node:vm';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const html = fs.readFileSync(path.join(root, 'index.html'), 'utf8');
const match = html.match(/<script>\s*([\s\S]*?)\s*<\/script>/);
assert.ok(match, 'expected the inline site script');
const startup = match[1].lastIndexOf('\n  loadAll().catch(');
assert.notEqual(startup, -1, 'could not isolate the network startup');
// Execute the actual page script and its DOM listeners, suppressing only the
// initial API request. Expose its real functions for offline assertions.
const script = match[1].slice(0, startup) + `\n  globalThis.subject = {
  FALLBACK_MODS, modsFromContents,
  renderPacks, startDownload, el
};\n})();`;

class Element {
  constructor(tag = 'div') {
    this.tag = tag; this.children = []; this.handlers = {}; this.style = {};
    this.classList = {add() {}, remove() {}};
    this.disabled = false; this._html = ''; this.textContent = '';
  }
  set innerHTML(value) { this._html = value; this.children = []; }
  get innerHTML() { return this._html; }
  appendChild(child) { this.children.push(child); return child; }
  removeChild(child) { this.children = this.children.filter(x => x !== child); }
  addEventListener(name, fn) { this.handlers[name] = fn; }
  setAttribute() {}
  click() { this.clicked = true; }
}
const nodes = new Map();
const document = {
  body: new Element('body'),
  createElement: tag => new Element(tag),
  getElementById: id => { if (!nodes.has(id)) nodes.set(id, new Element()); return nodes.get(id); },
  addEventListener() {},
};
let fetches = 0;
const sandbox = {
  document, window: {addEventListener() {}}, navigator: {}, AbortController,
  setTimeout: () => 0, clearTimeout() {}, setInterval: () => 0, clearInterval() {},
  fetch: async () => { fetches++; return {status: 404, ok: false}; },
};
vm.runInNewContext(script, sandbox, {filename: 'index.html'});
const s = sandbox.subject;
// ---------------------------------------------------------------------------
// Datapacks are retired (2026-11-05): the page must never offer a pack again.
// ---------------------------------------------------------------------------
assert.ok(!('FALLBACK_PACKS' in s), 'the static pack list must be gone');

// Even a stale packs-latest release with real .zip assets renders no download
// cards: renderPacks always produces the retired notice.
const base = 'https://github.com/vortaforge/core/releases/download/packs-latest/';

// The pack-asset shaper is gone, not merely neutered. A function that still
// accepts release assets is a function that can be re-enabled by deleting one
// `if (false)`; the page must have no such path at all.
assert.ok(!('packsFromReleaseAssets' in s), 'packsFromReleaseAssets must be removed');
assert.ok(!html.includes('packsFromReleaseAssets'), 'no pack-asset shaper in the page');
assert.ok(!/api\.github\.com\/repos\/[^\"'`]*\/releases\/tags\//.test(html),
  'the page must not build a packs-latest release URL');
// Even the retired tag name may only appear in prose, never in a URL or fetch.
assert.ok(!/fetch[A-Za-z]*\([^)]*RELEASE_TAG/.test(html),
  'RELEASE_TAG must never be fetched');

for (const list of [[], [{name: 'DailyBonus', zip: 'DailyBonus.zip', downloadUrl: base + 'DailyBonus.zip'}]]) {
  s.renderPacks(list, 'live');
  const nodes = s.el.packsGrid.children;
  assert.equal(nodes.length, 1, 'exactly one notice, never a card');
  assert.match(nodes[0].textContent, /retired/i);
  assert.ok(!nodes[0].children || nodes[0].children.length === 0, 'no action buttons');
}

// Retired notice must be present in the markup for no-JS readers too.
assert.match(html, /datapack programme is retired/i);

const mods = s.modsFromContents(['afk-manager', 'TEMPLATE-MOD', 'datapack-fixer', 'rtwrapper-mod']
  .map(name => ({name, type: 'dir'})));
assert.equal(mods.length, 1);
assert.equal(mods[0].dir, 'afk-manager');

// The download path itself still refuses a 404 and never starts a download.
const btn = new Element('button'), status = new Element();
const modAsset = {name: 'afk-manager.jar', zip: 'afk-manager.jar',
  downloadUrl: base + 'afk-manager.jar'};
await s.startDownload(modAsset, btn, status);
assert.equal(fetches, 1);
assert.match(status.textContent, /404/);
assert.equal(document.body.children.length, 0, '404 must not start a download');
console.log('Website retirement, mod list and 404 checks passed.');
