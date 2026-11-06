import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import fs from 'node:fs';
import { createRequire } from 'node:module';
import os from 'node:os';
import path from 'node:path';
import { test } from 'node:test';
import { pathToFileURL } from 'node:url';
import { assessProject, discoverProjects, isPermissionWarning, listProjectFiles, strictJsonDiagnostics } from '../policy.mjs';

function fixture(t) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'vortaforge-lint-test-'));
  t.after(() => fs.rmSync(root, { recursive: true, force: true }));
  return root;
}
function write(root, rel, text) {
  const file = path.join(root, rel);
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, text);
  return file;
}
const emptyAllowlist = { wardTestRoots: [], permissionWarnings: [] };

test('discovers nested datapacks and resource packs, excluding build output', (t) => {
  const root = fixture(t);
  write(root, 'packs/nested/pack/pack.mcmeta', '{}');
  write(root, 'packs/nested/pack/data/demo/function/main.mcfunction', 'say hi\n');
  write(root, 'packs/resource/pack.mcmeta', '{}');
  write(root, 'packs/resource/assets/minecraft/sounds.json', '{}');
  write(root, 'packs/build/ignored/pack.mcmeta', '{}');
  write(root, 'packs/build/ignored/data/foo/function/x.mcfunction', 'invalid\n');
  const found = discoverProjects([path.join(root, 'packs')]);
  assert.deepEqual(found, [path.join(root, 'packs/nested/pack'), path.join(root, 'packs/resource')]);
  assert.equal(listProjectFiles(found[0]).length, 2);
  assert.equal(listProjectFiles(found[1]).length, 2);
});

test('lint discovery fails rather than following symlinked inputs', (t) => {
  const root = fixture(t);
  const pack = path.join(root, 'packs/demo');
  write(pack, 'pack.mcmeta', '{}');
  write(pack, 'data/demo/function/real.mcfunction', 'say hi\n');
  const outside = write(root, 'outside.mcfunction', 'say outside\n');
  fs.symlinkSync(outside, path.join(pack, 'data/demo/function/link.mcfunction'));
  assert.throws(() => discoverProjects([path.join(root, 'packs')]), /symlinks in lint inputs/);
  assert.throws(() => listProjectFiles(pack), /symlinks in lint inputs/);
});

test('strict JSON rejects invalid JSON and invalid UTF-8 without echoing source', (t) => {
  const root = fixture(t);
  const good = write(root, 'good.json', '{"values":[]}');
  const bad = write(root, 'bad.json', '{"secret":"never-echo-this",}');
  const invalidUtf8 = write(root, 'pack.mcmeta', Buffer.from([0xff, 0xfe]));
  const errors = strictJsonDiagnostics([good, bad, invalidUtf8]);
  assert.equal(errors.length, 2);
  assert.equal(errors.some((e) => e.message.includes('never-echo-this')), false);
  assert.deepEqual(errors.map((e) => e.file), [bad, invalidUtf8]);
});

test('incomplete or missing diagnostics fail closed and preserve path casing', (t) => {
  const root = fixture(t);
  const pack = path.join(root, 'MixedCasePack');
  const first = write(pack, 'data/demo/function/Good.mcfunction', 'say hi\n');
  const second = write(pack, 'pack.mcmeta', '{}');
  const result = { analyzedFiles: 2, totalFiles: 2, cancelled: false };
  const diagnostics = new Map([[pathToFileURL(first).href, []], [pathToFileURL(second).href, []]]);
  const common = { projectRoot: pack, repoRoot: root, expectedFiles: [first, second], allowlist: emptyAllowlist };
  assert.equal(assessProject({ ...common, diagnosticsByUri: diagnostics, serverResult: result }).checkedFiles, 2);
  diagnostics.delete(pathToFileURL(first).href);
  assert.throws(() => assessProject({ ...common, diagnosticsByUri: diagnostics, serverResult: result }), /did not publish/);
  assert.throws(() => assessProject({ ...common, diagnosticsByUri: diagnostics, serverResult: { ...result, cancelled: true } }), /incomplete/);
  assert.throws(() => assessProject({ ...common, diagnosticsByUri: diagnostics, serverResult: { ...result, analyzedFiles: 1 } }), /incomplete/);
});

test('permission exceptions require exact path, diagnostic and unchanged file hash', (t) => {
  const root = fixture(t);
  const file = write(root, 'packs/wrapper/data/x/function/stop.mcfunction', 'stop\n');
  const sha256 = createHash('sha256').update(fs.readFileSync(file)).digest('hex');
  const allowlist = { ...emptyAllowlist, permissionWarnings: [{ path: 'packs/wrapper/data/x/function/stop.mcfunction', sha256, requiredPermission: 4 }] };
  const diagnostic = { severity: 1, message: 'Permission level 4 is required, which is higher than 2 defined in config' };
  assert.equal(isPermissionWarning(root, file, diagnostic, allowlist), true);
  assert.equal(isPermissionWarning(root, file, { ...diagnostic, message: 'Another error' }, allowlist), false);
  fs.appendFileSync(file, '# changed\n');
  assert.equal(isPermissionWarning(root, file, diagnostic, allowlist), false);
});

test('Ward exclusions apply only to explicitly named test directories', (t) => {
  const root = fixture(t);
  const pack = path.join(root, 'packs/daily');
  const ward = write(pack, 'data/demo/test/ward.mcfunction', 'assert anything\n');
  const real = write(pack, 'data/demo/function/real.mcfunction', 'say hi\n');
  const diagnostics = new Map([[pathToFileURL(ward).href, [{ severity: 1, message: 'Ward command' }]],
    [pathToFileURL(real).href, []]]);
  const result = assessProject({ projectRoot: pack, repoRoot: root, expectedFiles: [ward, real], diagnosticsByUri: diagnostics,
    serverResult: { analyzedFiles: 2, totalFiles: 2, cancelled: false },
    allowlist: { ...emptyAllowlist, wardTestRoots: ['packs/daily/data/demo/test/'] } });
  assert.equal(result.ignoredFiles, 1);
  assert.equal(result.ignoredDiagnostics, 1);
  assert.equal(result.errors.length, 0);
});

test('patched decompressor rejects an archive attempting to write through an escaping symlink', async (t) => {
  const root = fixture(t);
  const outside = path.join(root, 'outside');
  const output = path.join(root, 'output');
  fs.mkdirSync(outside); fs.mkdirSync(output);
  const require = createRequire(import.meta.url);
  const core = require.resolve('@spyglassmc/core/package.json');
  const decompressor = createRequire(core).resolve('decompress');
  const pkg = JSON.parse(fs.readFileSync(path.join(path.dirname(decompressor), 'package.json'), 'utf8'));
  assert.equal(pkg.name, '@xhmikosr/decompress');
  assert.equal(pkg.version, '11.1.4');
  const { default: decompress } = await import(pathToFileURL(decompressor).href);
  // ZIP contains a symlink escape -> ../outside and a file escape/marker.
  const zip = Buffer.from('UEsDBBQAAAAAAAAAIQAGUP3wCgAAAAoAAAAGAAAAZXNjYXBlLi4vb3V0c2lkZVBLAwQUAAAAAAAiR15dxv2fexAAAAAQAAAADQAAAGVzY2FwZS9tYXJrZXJ1bmV4cGVjdGVkLXdyaXRlUEsBAhQDFAAAAAAAAAAhAAZQ/fAKAAAACgAAAAYAAAAAAAAAAAAAAP+hAAAAAGVzY2FwZVBLAQIUAxQAAAAAACJHXl3G/Z97EAAAABAAAAANAAAAAAAAAAAAAACAAS4AAABlc2NhcGUvbWFya2VyUEsFBgAAAAACAAIAbwAAAGkAAAAAAA==', 'base64');
  await assert.rejects(decompress(zip, output));
  assert.equal(fs.existsSync(path.join(outside, 'marker')), false);
});
