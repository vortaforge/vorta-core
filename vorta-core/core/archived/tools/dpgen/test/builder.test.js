'use strict';
// Offline tests for dpgen's config validation and file-map generation.
// Run with: npm test   (uses the built-in node:test runner, Node >= 18)

const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const yaml = require('js-yaml');
const { buildFileMap, validateConfig, ConfigError } = require('../builder');

const EXAMPLES = path.join(__dirname, '..', 'examples');
const load = (name) => yaml.load(fs.readFileSync(path.join(EXAMPLES, name), 'utf8'));

for (const name of ['example.yaml', 'example-v2.yaml']) {
  test(`${name} validates and builds a pack`, () => {
    const config = load(name);
    validateConfig(config);
    const files = buildFileMap(config);
    assert.ok('pack.mcmeta' in files, 'pack.mcmeta is generated');
    for (const key of Object.keys(files)) {
      assert.ok(!key.includes('..') && !path.isAbsolute(key), `unsafe path: ${key}`);
    }
  });
}

test('example tick/load functions are registered in minecraft tags', () => {
  const files = buildFileMap(load('example.yaml'));
  assert.deepEqual(files['data/minecraft/tags/function/tick.json'].values, ['testns:main']);
  assert.ok(files['data/minecraft/tags/function/load.json'].values.includes('testns:init'));
});

test('an invalid namespace id is rejected with ConfigError', () => {
  const config = load('example.yaml');
  config.namespaces[0].id = 'Bad Namespace!';
  assert.throws(() => validateConfig(config), (e) => e instanceof ConfigError && /namespaces\/0\/id/.test(e.message));
});

test('a config without namespaces is rejected with ConfigError', () => {
  const config = load('example.yaml');
  delete config.namespaces;
  assert.throws(() => validateConfig(config), (e) => e instanceof ConfigError && /namespaces/.test(e.message));
});
