#!/usr/bin/env node
import fs from 'node:fs';
import { createRequire } from 'node:module';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { analyzeProject } from './session.mjs';
import { assessProject, discoverProjects, listProjectFiles, strictJsonDiagnostics } from './policy.mjs';

const here = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(here, '../..');
const require = createRequire(import.meta.url);

function validateInstalledDependencies() {
  const serverPackage = require.resolve('@spyglassmc/language-server/package.json');
  const server = JSON.parse(fs.readFileSync(serverPackage, 'utf8'));
  if (server.version !== '0.4.70') throw new Error(`expected Spyglass 0.4.70, got ${server.version}`);
  const corePackage = createRequire(serverPackage).resolve('@spyglassmc/core/package.json');
  const decompressorEntry = createRequire(corePackage).resolve('decompress');
  const decompressor = JSON.parse(fs.readFileSync(path.join(path.dirname(decompressorEntry), 'package.json'), 'utf8'));
  if (decompressor.name !== '@xhmikosr/decompress' || decompressor.version !== '11.1.4') {
    throw new Error(`unsafe or unexpected decompress dependency: ${decompressor.name}@${decompressor.version}; run npm ci with the locked override`);
  }
}

function parseArguments(args) {
  const roots = [];
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--help') {
      console.log('Usage: lint_datapacks.sh [--project PACK_ROOT]...\nWithout --project, discovers packs and examples recursively.');
      process.exit(0);
    }
    if (args[i] !== '--project' || !args[i + 1]) throw new Error(`unknown or incomplete argument: ${args[i]}`);
    const root = path.resolve(args[++i]);
    if (!fs.existsSync(path.join(root, 'pack.mcmeta'))) throw new Error(`not a pack root: ${root}`);
    roots.push(root);
  }
  return roots.length ? [...new Set(roots)].sort() : discoverProjects([path.join(repoRoot, 'packs'), path.join(repoRoot, 'examples')]);
}

function printDiagnostic(kind, item) {
  const rel = path.relative(repoRoot, item.file) || item.file;
  console.log(`${kind}: ${rel}:${item.line}:${item.column}: ${item.message} [${item.source}]`);
}

async function main() {
  validateInstalledDependencies();
  const allowlist = JSON.parse(fs.readFileSync(path.join(here, 'allowlist.json'), 'utf8'));
  if (!Array.isArray(allowlist.wardTestRoots) || !Array.isArray(allowlist.permissionWarnings)) throw new Error('invalid lint allowlist');
  const projects = parseArguments(process.argv.slice(2));
  if (!projects.length) throw new Error('no datapack or resource-pack roots found');
  let errorCount = 0, warningCount = 0, checkedCount = 0, ignoredCount = 0;
  console.log(`Spyglass 0.4.70: analyzing ${projects.length} project(s); vanilla data may be downloaded and cached. No Minecraft server is started.`);
  for (const projectRoot of projects) {
    const files = listProjectFiles(projectRoot);
    if (!files.length) throw new Error(`no supported lint files under ${projectRoot}`);
    const display = path.relative(repoRoot, projectRoot) || projectRoot;
    console.log(`\n[Spyglass] ${display}: ${files.length} candidate file(s)`);
    // Spyglass may publish an empty diagnostic set for malformed JSON, so a
    // second strict UTF-8/JSON parser is required rather than trusting that set.
    const jsonErrors = strictJsonDiagnostics(files);
    const session = await analyzeProject(projectRoot);
    const result = assessProject({ projectRoot, repoRoot, expectedFiles: files, ...session, allowlist });
    if (session.versionInfo) console.log(`[Spyglass] ${session.versionInfo}`);
    for (const item of jsonErrors) printDiagnostic('ERROR', item);
    for (const item of result.errors) printDiagnostic('ERROR', item);
    for (const item of result.warnings) printDiagnostic('WARNING', item);
    console.log(`[Spyglass] ${result.serverAnalyzed} server-analyzed, ${result.checkedFiles} coverage-verified, ` +
      `${result.ignoredFiles} Ward file(s) excluded; ${result.errors.length + jsonErrors.length} error(s), ${result.warnings.length} warning(s).`);
    errorCount += result.errors.length + jsonErrors.length; warningCount += result.warnings.length;
    checkedCount += result.checkedFiles; ignoredCount += result.ignoredFiles;
  }
  console.log(`\nSpyglass summary: ${projects.length} project(s), ${checkedCount} coverage-verified file(s), ` +
    `${ignoredCount} Ward file(s) excluded, ${errorCount} error(s), ${warningCount} warning(s).`);
  if (errorCount) process.exitCode = 2;
}

main().catch((error) => {
  console.error(`Spyglass lint infrastructure failure: ${error?.stack ?? error}`);
  process.exitCode = 3;
});
