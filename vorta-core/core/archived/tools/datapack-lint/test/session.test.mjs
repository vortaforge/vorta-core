import assert from 'node:assert/strict';
import { PassThrough } from 'node:stream';
import { test } from 'node:test';

test('the production language-server session imports with the locked JSON-RPC package', async () => {
  // Import the actual production module, not a reimplementation of its
  // package path. This catches non-exported subpaths before lintDatapacks runs.
  const session = await import('../session.mjs');
  assert.equal(typeof session.analyzeProject, 'function');
});

test('the installed Node JSON-RPC streams exchange a request and response', { timeout: 10000 }, async (t) => {
  const { createMessageConnection, StreamMessageReader, StreamMessageWriter } =
    await import('vscode-jsonrpc/node');
  const clientToServer = new PassThrough();
  const serverToClient = new PassThrough();
  const client = createMessageConnection(new StreamMessageReader(serverToClient), new StreamMessageWriter(clientToServer));
  const server = createMessageConnection(new StreamMessageReader(clientToServer), new StreamMessageWriter(serverToClient));
  t.after(() => {
    client.dispose(); server.dispose(); clientToServer.destroy(); serverToClient.destroy();
  });
  server.onRequest('test/ping', ({ value }) => ({ echoed: value }));
  server.listen(); client.listen();
  const response = await client.sendRequest('test/ping', { value: 42 });
  assert.deepEqual(response, { echoed: 42 });
});
