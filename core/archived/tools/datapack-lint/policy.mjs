import { createHash } from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const IGNORED_DIRS = new Set(['.git', '.gradle', 'build', 'node_modules', '__pycache__']);

export function relativeInside(root, candidate) {
  const relative = path.relative(path.resolve(root), path.resolve(candidate));
  return relative && relative !== '..' && !relative.startsWith(`..${path.sep}`) && !path.isAbsolute(relative)
    ? relative.split(path.sep).join('/') : null;
}

function walk(root, visit) {
  for (const entry of fs.readdirSync(root, { withFileTypes: true }).sort((a, b) => a.name.localeCompare(b.name))) {
    const file = path.join(root, entry.name);
    if (entry.isSymbolicLink()) {
      // Neither discovery nor coverage may silently follow links outside the checkout.
      throw new Error(`symlinks in lint inputs are not supported: ${file}`);
    }
    if (entry.isDirectory()) {
      if (!entry.name.startsWith('.') && !IGNORED_DIRS.has(entry.name)) walk(file, visit);
    } else if (entry.isFile()) {
      visit(file);
    }
  }
}

export function discoverProjects(roots) {
  const projects = new Set();
  for (const root of roots) {
    if (!fs.existsSync(root)) throw new Error(`lint root does not exist: ${root}`);
    walk(root, (file) => {
      if (path.basename(file) !== 'pack.mcmeta') return;
      const folder = path.dirname(file);
      if (fs.existsSync(path.join(folder, 'data')) || fs.existsSync(path.join(folder, 'assets'))) {
        projects.add(path.resolve(folder));
      }
    });
  }
  return [...projects].sort();
}

export function listProjectFiles(root) {
  const files = [];
  walk(root, (file) => {
    const rel = relativeInside(root, file);
    const ext = path.extname(file).toLowerCase();
    if (['.mcfunction', '.mcmeta', '.mcdoc', '.snbt'].includes(ext) ||
        (ext === '.json' && /(^|\/)(data|assets)\//.test(rel))) files.push(path.resolve(file));
  });
  return files.sort();
}

export function strictJsonDiagnostics(files) {
  const errors = [];
  const decoder = new TextDecoder('utf-8', { fatal: true });
  for (const file of files) {
    if (!['.json', '.mcmeta'].includes(path.extname(file).toLowerCase())) continue;
    try {
      JSON.parse(decoder.decode(fs.readFileSync(file)));
    } catch (error) {
      // Some Node versions embed source excerpts in JSON.parse errors. Do not
      // echo them: malformed input could contain sensitive text.
      const location = /\(line (\d+) column (\d+)\)/.exec(String(error.message));
      errors.push({ file, line: Number(location?.[1] ?? 1), column: Number(location?.[2] ?? 1),
        message: `Invalid UTF-8 or JSON (${error.name})`, source: 'strict-json' });
    }
  }
  return errors;
}

export function isWardFile(repoRoot, file, allowlist) {
  const rel = relativeInside(repoRoot, file);
  return rel !== null && allowlist.wardTestRoots.some((prefix) => rel.startsWith(prefix));
}

export function isPermissionWarning(repoRoot, file, diagnostic, allowlist) {
  const rel = relativeInside(repoRoot, file);
  const entry = allowlist.permissionWarnings.find((item) => item.path === rel);
  if (!entry || diagnostic.severity !== 1 ||
      diagnostic.message !== `Permission level ${entry.requiredPermission} is required, which is higher than 2 defined in config`) return false;
  const actualHash = createHash('sha256').update(fs.readFileSync(file)).digest('hex');
  return actualHash === entry.sha256;
}

export function assessProject({ projectRoot, repoRoot, expectedFiles, diagnosticsByUri, serverResult, allowlist }) {
  if (!serverResult || serverResult.cancelled || !Number.isInteger(serverResult.totalFiles) ||
      !Number.isInteger(serverResult.analyzedFiles) || serverResult.totalFiles < 1 ||
      serverResult.analyzedFiles !== serverResult.totalFiles) {
    throw new Error(`Spyglass analysis was incomplete or cancelled: ${JSON.stringify(serverResult)}`);
  }

  const byPath = new Map();
  const expected = new Set(expectedFiles.map((file) => path.resolve(file)));
  for (const [uri, diagnostics] of diagnosticsByUri) {
    if (!uri.startsWith('file:')) continue;
    const file = path.resolve(fileURLToPath(uri));
    // Ignore build/cache outputs and unrelated files, exactly as discovery does.
    if (relativeInside(projectRoot, file) !== null && expected.has(file)) byPath.set(file, diagnostics);
  }
  const checked = expectedFiles.filter((file) => !isWardFile(repoRoot, file, allowlist));
  const missing = checked.filter((file) => !byPath.has(path.resolve(file)));
  if (missing.length || serverResult.analyzedFiles < checked.length) {
    const sample = missing.slice(0, 5).map((f) => relativeInside(projectRoot, f)).join(', ');
    throw new Error(`Spyglass did not publish diagnostics for ${missing.length}/${checked.length} expected files` +
      `${sample ? `: ${sample}` : ''}; server reported ${serverResult.analyzedFiles} analyzed`);
  }

  const errors = [];
  const warnings = [];
  let ignoredDiagnostics = 0;
  for (const [file, diagnostics] of byPath) {
    for (const diagnostic of diagnostics) {
      if (isWardFile(repoRoot, file, allowlist)) { ignoredDiagnostics++; continue; }
      const item = { file, line: (diagnostic.range?.start?.line ?? 0) + 1,
        column: (diagnostic.range?.start?.character ?? 0) + 1,
        message: String(diagnostic.message ?? 'Spyglass returned an unspecified diagnostic'),
        source: diagnostic.source || 'Spyglass' };
      if (isPermissionWarning(repoRoot, file, diagnostic, allowlist)) {
        warnings.push({ ...item, message: `${item.message} (hash-bound exception; runtime permission is not checked)` });
      } else if (diagnostic.severity === 2) {
        warnings.push(item);
      } else if (diagnostic.severity === undefined || diagnostic.severity === 1) {
        errors.push(item);
      }
    }
  }
  return { errors, warnings, checkedFiles: checked.length,
    ignoredFiles: expectedFiles.length - checked.length, ignoredDiagnostics,
    serverAnalyzed: serverResult.analyzedFiles };
}
