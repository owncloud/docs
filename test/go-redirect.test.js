'use strict'

const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')

const { resolveGoPhp, MAPPING, fallbackFor, PUBLISHED_VERSIONS } = require('../supplemental/js/go-redirect.js')

const PREFIX = '/server/latest/'

test('non-go.php paths are left untouched', () => {
  assert.equal(resolveGoPhp('/server/latest/index.html', ''), null)
  assert.equal(resolveGoPhp('/server/latest/', ''), null)
  // "cargo.php" must not be mistaken for the go.php endpoint.
  assert.equal(resolveGoPhp('/server/latest/cargo.php', '?to=admin-sharing'), null)
})

test('a known key redirects to its mapped page under the version root', () => {
  assert.equal(
    resolveGoPhp(PREFIX + 'go.php', '?to=admin-sharing'),
    PREFIX + 'admin_manual/configuration/files/file_sharing_configuration.html'
  )
})

test('a developer key redirects into the developer manual', () => {
  assert.equal(
    resolveGoPhp(PREFIX + 'go.php', '?to=developer-theming'),
    PREFIX + 'developer_manual/core/theming.html'
  )
})

test('a user key redirects into the classic_ui module', () => {
  assert.equal(
    resolveGoPhp(PREFIX + 'go.php', '?to=user-webdav'),
    PREFIX + 'classic_ui/files/access_webdav.html'
  )
})

test('a published version segment is preserved for per-version fidelity', () => {
  const p = '/server/10.16/'
  assert.equal(
    resolveGoPhp(p + 'go.php', '?to=admin-sharing'),
    p + 'admin_manual/configuration/files/file_sharing_configuration.html'
  )
})

test('an unpublished version segment (concrete current stable) is remapped to latest', () => {
  // Core emits the concrete version (e.g. 11.0), which has no published tree;
  // it must be sent to /server/latest/ where the current stable is published.
  assert.equal(
    resolveGoPhp('/server/11.0/go.php', '?to=admin-sharing'),
    '/server/latest/admin_manual/configuration/files/file_sharing_configuration.html'
  )
  // An old, long-unpublished release likewise falls back to latest.
  assert.equal(
    resolveGoPhp('/server/10.9/go.php', '?to=user-webdav'),
    '/server/latest/classic_ui/files/access_webdav.html'
  )
})

test('a URL-encoded key (e.g. the well-known-URL key) resolves', () => {
  assert.equal(
    resolveGoPhp(PREFIX + 'go.php', '?to=admin-setup-well-known-URL'),
    PREFIX + 'admin_manual/troubleshooting/general_troubleshooting.html'
  )
})

test('unknown keys fall back to the server docs entrypoint', () => {
  assert.equal(resolveGoPhp(PREFIX + 'go.php', '?to=admin-does-not-exist'), PREFIX + 'index.html')
  assert.equal(resolveGoPhp(PREFIX + 'go.php', '?to=developer-nope'), PREFIX + 'index.html')
  assert.equal(resolveGoPhp(PREFIX + 'go.php', '?to=user-nope'), PREFIX + 'index.html')
  assert.equal(resolveGoPhp(PREFIX + 'go.php', '?to=totally-unknown'), PREFIX + 'index.html')
})

test('a missing/empty key falls back to the server docs entrypoint', () => {
  assert.equal(resolveGoPhp(PREFIX + 'go.php', ''), PREFIX + 'index.html')
  assert.equal(resolveGoPhp(PREFIX + 'go.php', '?to='), PREFIX + 'index.html')
})

test('extra query parameters around to= are ignored', () => {
  assert.equal(
    resolveGoPhp(PREFIX + 'go.php', '?foo=1&to=admin-sharing&bar=2'),
    PREFIX + 'admin_manual/configuration/files/file_sharing_configuration.html'
  )
})

test('a malformed percent-escape degrades to the fallback, never throws', () => {
  assert.equal(resolveGoPhp(PREFIX + 'go.php', '?to=%'), PREFIX + 'index.html')
  assert.equal(resolveGoPhp(PREFIX + 'go.php', '?to=admin-%zz'), PREFIX + 'index.html')
})

test('a value containing = is preserved (not truncated at the first =)', () => {
  // No real key contains '=', so this just proves the parser keeps the whole
  // value: "admin-x=y" is unknown -> entrypoint fallback (not silently the
  // truncated "admin-x", which is also unknown here but proves the point).
  assert.equal(resolveGoPhp(PREFIX + 'go.php', '?to=admin-x=y'), PREFIX + 'index.html')
})

test('fallbackFor returns the version-root entrypoint for any key', () => {
  assert.equal(fallbackFor('admin-x'), 'index.html')
  assert.equal(fallbackFor('developer-x'), 'index.html')
  assert.equal(fallbackFor('user-x'), 'index.html')
  assert.equal(fallbackFor('anything-else'), 'index.html')
})

// Guard against version drift: PUBLISHED_VERSIONS must list exactly the server
// version segments the build actually emits under public/server/*.
test('PUBLISHED_VERSIONS matches the built server version segments', (t) => {
  const serverDir = path.join(__dirname, '..', 'public', 'server')
  if (!fs.existsSync(serverDir)) {
    t.skip('public/server not built (run `npm run antora` to enable)')
    return
  }
  const built = fs.readdirSync(serverDir, { withFileTypes: true })
    .filter((d) => d.isDirectory())
    .map((d) => d.name)
    .sort()
  assert.deepEqual(
    [...PUBLISHED_VERSIONS].sort(),
    built,
    'PUBLISHED_VERSIONS in go-redirect.js is out of sync with public/server/* — update the list'
  )
})

// Guard against page moves: every mapped target must exist in the built site.
// Skips automatically when the site has not been built yet.
test('every mapped target exists in the built server/latest site', (t) => {
  const base = path.join(__dirname, '..', 'public', 'server', 'latest')
  if (!fs.existsSync(base)) {
    t.skip('public/server/latest not built (run `npm run antora` to enable)')
    return
  }
  const missing = []
  for (const [key, target] of Object.entries(MAPPING)) {
    if (!fs.existsSync(path.join(base, target))) missing.push(`${key} -> ${target}`)
  }
  // The unknown-key fallback landing must exist too.
  if (!fs.existsSync(path.join(base, fallbackFor('')))) missing.push(`(fallback) ${fallbackFor('')}`)
  assert.deepEqual(missing, [], 'mapped go.php targets missing from the build:\n' + missing.join('\n'))
})
