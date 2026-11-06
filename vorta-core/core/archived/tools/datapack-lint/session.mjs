import { spawn } from 'node:child_process';
import { createRequire } from 'node:module';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { createMessageConnection, StreamMessageReader, StreamMessageWriter } from 'vscode-jsonrpc/node';

const require = createRequire(import.meta.url);

function milliseconds(name, fallback) {
  if (!process.env[name]) return fallback;
  const value = Number(process.env[name]);
  if (!Number.isSafeInteger(value) || value < 1 || value > 900000) throw new Error(`${name} must be 1..900000 milliseconds`);
  return value;
}

async function withTimeout(promise, timeout, label) {
  let timer;
  try {
    return await Promise.race([promise, new Promise((_, reject) => {
      timer = setTimeout(() => reject(new Error(`${label} timed out after ${timeout} ms`)), timeout);
    })]);
  } finally { clearTimeout(timer); }
}

export async function analyzeProject(projectRoot) {
  const packageFile = require.resolve('@spyglassmc/language-server/package.json');
  const server = path.join(path.dirname(packageFile), 'bin', 'server.js');
  const child = spawn(process.execPath, [server, '--stdio'], { stdio: ['pipe', 'pipe', 'pipe'] });
  let stderr = '';
  child.stderr.on('data', (chunk) => { stderr = (stderr + chunk.toString()).slice(-4000); });
  const failed = new Promise((_, reject) => {
    child.once('error', (error) => reject(new Error(`Spyglass failed to start: ${error.message}`)));
    child.once('exit', (code, signal) => reject(new Error(`Spyglass exited early (code ${code}, signal ${signal})${stderr ? `: ${stderr}` : ''}`)));
  });
  // A normal shutdown also fires 'exit'; install a handler even if no request is pending.
  failed.catch(() => {});
  const connection = createMessageConnection(new StreamMessageReader(child.stdout), new StreamMessageWriter(child.stdin));
  const diagnosticsByUri = new Map();
  const serverErrors = [];
  let versionInfo = '';
  let initialized = false;
  let resolveReady;
  const ready = new Promise((resolve) => { resolveReady = resolve; });
  connection.onNotification('$/progress', (params) => {
    if (params?.token === 'initialize' && params.value?.kind === 'end') resolveReady();
  });
  connection.onNotification('textDocument/publishDiagnostics', (params) => {
    if (typeof params?.uri === 'string' && Array.isArray(params.diagnostics)) diagnosticsByUri.set(params.uri, params.diagnostics);
    else serverErrors.push('malformed publishDiagnostics notification');
  });
  connection.onNotification('window/logMessage', (params) => {
    const message = String(params?.message ?? '');
    if (message.includes('[resolveConfiguredVersion]')) versionInfo = message;
    if (params?.type === 1) serverErrors.push(message);
    if (process.env.SPYGLASS_DEBUG === '1') console.error(`[Spyglass] ${message}`);
  });
  connection.onNotification('window/showMessage', (params) => {
    if (params?.type === 1) serverErrors.push(String(params.message));
    else console.error(`[Spyglass] ${String(params?.message ?? '')}`);
  });
  connection.onRequest('client/registerCapability', () => null);
  connection.onRequest('client/unregisterCapability', () => null);
  connection.onRequest('window/workDoneProgress/create', () => null);
  connection.onRequest('window/showMessageRequest', () => null);
  connection.onRequest('workspace/configuration', (params) => (params?.items ?? []).map(() => ({})));
  const rootUri = `${pathToFileURL(path.resolve(projectRoot)).href.replace(/\/$/, '')}/`;
  connection.onRequest('workspace/workspaceFolders', () => [{ uri: rootUri, name: path.basename(projectRoot) }]);
  connection.listen();
  const request = (promise, duration, label) => withTimeout(Promise.race([promise, failed]), duration, label);
  try {
    const readyTimeout = milliseconds('SPYGLASS_READY_TIMEOUT_MS', 180000);
    const analyzeTimeout = milliseconds('SPYGLASS_ANALYZE_TIMEOUT_MS', 300000);
    await request(connection.sendRequest('initialize', {
      processId: process.pid,
      clientInfo: { name: 'vortaforge-datapack-lint', version: '1.0.0' },
      locale: 'en', rootUri, rootPath: path.resolve(projectRoot),
      capabilities: {
        workspace: { workspaceFolders: true, configuration: true,
          didChangeWatchedFiles: { dynamicRegistration: true }, didChangeConfiguration: { dynamicRegistration: true } },
        window: { workDoneProgress: true },
        textDocument: { publishDiagnostics: { relatedInformation: true } }
      },
      initializationOptions: {}, workspaceFolders: [{ uri: rootUri, name: path.basename(projectRoot) }]
    }), readyTimeout, 'Spyglass initialize');
    initialized = true;
    connection.sendNotification('initialized', {});
    await request(ready, readyTimeout, 'Spyglass project initialization');
    const serverResult = await request(connection.sendRequest('spyglassmc/analyzeProject'), analyzeTimeout, 'Spyglass project analysis');
    if (serverErrors.length) throw new Error(`Spyglass logged ${serverErrors.length} error(s): ${serverErrors.slice(0, 3).join('; ')}`);
    return { diagnosticsByUri, serverResult, versionInfo };
  } finally {
    let exitRequested = false;
    if (initialized && child.exitCode === null && child.signalCode === null) {
      try {
        await withTimeout(connection.sendRequest('shutdown'), 3000, 'Spyglass shutdown');
        connection.sendNotification('exit');
        exitRequested = true;
      } catch { /* The server may already be gone; terminate below. */ }
    }
    connection.dispose();
    if (child.exitCode === null && child.signalCode === null) {
      await new Promise((resolve) => {
        const terminate = setTimeout(() => child.kill('SIGTERM'), exitRequested ? 1500 : 0);
        const force = setTimeout(() => { child.kill('SIGKILL'); resolve(); }, 3000);
        child.once('exit', () => { clearTimeout(terminate); clearTimeout(force); resolve(); });
      });
    }
  }
}
