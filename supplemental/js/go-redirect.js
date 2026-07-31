/*
 * Static replacement for the legacy server-side `go.php` documentation
 * redirector.
 *
 * ownCloud core (lib/private/legacy/defaults.php::buildDocLinkToKey) builds
 * deep links into the docs as:
 *
 *     https://doc.owncloud.com/server/<version>/go.php?to=<key>
 *
 * On the old Sphinx site `go.php` was a PHP script that 302-redirected the
 * key to the real page (see owncloud/enterprise .../ocdoc/go.php). The docs
 * now build as a static Antora site on GitHub Pages, which executes no PHP and
 * ignores the query string, so every one of those links 404s. Because every
 * ownCloud server already deployed keeps emitting `go.php?to=` links, we cannot
 * fix this purely in core -- we must honor the old URL shape on the site.
 *
 * GitHub Pages serves the site-wide custom 404 page for the missing `go.php`
 * path (a file literally named `go.php` would be served as
 * application/x-httpd-php, i.e. downloaded, so a static stub does NOT work).
 * This script is loaded from the page <head> on EVERY page; it is a no-op
 * except when the current path ends in `go.php`, in which case it reproduces
 * the original redirector against the current Antora page layout.
 *
 * The key -> target map is derived from the `:page-aliases: go/<key>.adoc`
 * stubs the docs already generate (the maintained source of truth), plus the
 * keys core requests that had no alias yet. Targets are relative to the
 * version root (e.g. /server/latest/), matching how the links are versioned.
 *
 * Version remap: core emits the CONCRETE server version in the path (e.g.
 * /server/11.0/go.php), but the site publishes the current stable only under
 * /server/latest/ (site.yml latest_version_segment_strategy: replace, because
 * GitHub Pages cannot 302 a version segment to latest). So a version segment
 * without its own published tree (11.0, older releases) is remapped to
 * `latest`; segments that ARE published (e.g. 10.16) are kept for per-version
 * fidelity. PUBLISHED_VERSIONS is checked in CI against the built
 * public/server/* directories so it cannot silently go stale.
 */
;(function (root) {
  'use strict'

  // Server version path segments that have their own published doc tree.
  // Anything else (concrete current-stable, unpublished older releases) is
  // served under `latest`. Kept in sync with the build by the unit tests.
  // Here `latest` is the current stable (11.0, published via
  // latest_version_segment: latest). There is no `next` server version: master
  // carries the released version rather than a prerelease.
  var PUBLISHED_VERSIONS = ['10.16', 'latest']

  // key -> path relative to the version root (…/server/<version>/).
  var MAPPING = {
    // -- admin manual --------------------------------------------------------
    'admin-background-jobs': 'admin_manual/configuration/server/background_jobs_configuration.html',
    'admin-backup': 'admin_manual/maintenance/backup_and_restore/backup.html',
    'admin-cli-upgrade': 'admin_manual/configuration/server/occ_command.html',
    'admin-config': 'admin_manual/configuration/server/config_sample_php_parameters.html',
    'admin-db-conversion': 'admin_manual/configuration/database/db_conversion.html',
    'admin-dir_permissions': 'admin_manual/installation/installation_wizard.html',
    'admin-email': 'admin_manual/configuration/server/email_configuration.html',
    'admin-encryption': 'admin_manual/configuration/files/encryption/encryption_configuration.html',
    'admin-enterprise-license': 'admin_manual/enterprise/installation/install.html',
    'admin-external-storage': 'admin_manual/configuration/files/external_storage/configuration.html',
    'admin-install': 'admin_manual/installation/index.html',
    'admin-ldap': 'admin_manual/configuration/user/user_auth_ldap.html',
    'admin-logfiles': 'admin_manual/troubleshooting/general_troubleshooting.html',
    'admin-marketplace-apps': 'admin_manual/maintenance/upgrading/marketplace_apps.html',
    'admin-monitoring': 'admin_manual/installation/deployment_considerations.html',
    'admin-performance': 'admin_manual/configuration/server/oc_server_tuning.html',
    'admin-php-fpm': 'admin_manual/installation/configuration_notes_and_tips.html',
    'admin-reverse-proxy': 'admin_manual/configuration/server/reverse_proxy_configuration.html',
    'admin-security': 'admin_manual/configuration/server/harden_server.html',
    'admin-setup-well-known-URL': 'admin_manual/troubleshooting/general_troubleshooting.html',
    'admin-sharing': 'admin_manual/configuration/files/file_sharing_configuration.html',
    'admin-sharing-federated': 'admin_manual/configuration/files/federated_cloud_sharing_configuration.html',
    'admin-source_install': 'admin_manual/installation/source_installation.html',
    'admin-transactional-locking': 'admin_manual/configuration/files/files_locking_transactional.html',
    'admin-untrusted-domains': 'admin_manual/maintenance/migrating.html',
    'enable-http-strict-transport-security': 'admin_manual/configuration/server/harden_server.html',
    'use-https': 'admin_manual/configuration/server/harden_server.html',

    // -- developer manual ----------------------------------------------------
    'admin-code-integrity': 'developer_manual/app/advanced/code_signing.html',
    'admin-provisioning-api': 'developer_manual/core/apis/provisioning-api.html',
    'developer-code-integrity': 'developer_manual/app/advanced/code_signing.html',
    'developer-theming': 'developer_manual/core/theming.html',

    // -- user manual (now the "classic_ui" module) ---------------------------
    'user-encryption': 'classic_ui/files/encrypting_files.html',
    'user-files': 'classic_ui/files/index.html',
    'user-manual': 'classic_ui/index.html',
    'user-sharing-federated': 'classic_ui/files/federated_cloud_sharing.html',
    'user-sync-calendars': 'classic_ui/apps/calendar.html',
    'user-sync-contacts': 'classic_ui/apps/contacts.html',
    'user-trashbin': 'classic_ui/files/deleted_file_management.html',
    'user-versions': 'classic_ui/files/version_control.html',
    'user-webdav': 'classic_ui/files/access_webdav.html'
  }

  // Landing page for an unknown/mistyped key. The original go.php split the
  // fallback by key prefix (admin_manual / developer_manual / user_manual), but
  // those manuals have since been reorganized and an unknown key has no better
  // destination than the server docs entrypoint, so we send every unknown key
  // to the version root (index.html) regardless of prefix. `key` is accepted
  // for signature stability and future per-prefix routing if ever needed.
  function fallbackFor (key) { // eslint-disable-line no-unused-vars
    return 'index.html'
  }

  /**
   * Given the current location's pathname and query string, return the URL to
   * redirect a legacy `go.php?to=<key>` request to, or null when this is not a
   * go.php request (so callers leave the page untouched).
   *
   * @param {string} pathname e.g. "/server/latest/go.php"
   * @param {string} search   e.g. "?to=admin-sharing"
   * @returns {string|null} the redirect target, relative to the site, or null
   */
  function resolveGoPhp (pathname, search) {
    // Only act on the exact legacy endpoint: a path segment named "go.php".
    if (!/\/go\.php$/.test(pathname)) return null

    var versionRoot = pathname.replace(/go\.php$/, '') // keeps trailing slash

    // Remap the version segment ".../server/<version>/" to a published one.
    // Core emits the concrete version, which usually has no published tree.
    versionRoot = versionRoot.replace(/(\/server\/)([^/]+)(\/)$/, function (m, pre, version, post) {
      return PUBLISHED_VERSIONS.indexOf(version) === -1 ? pre + 'latest' + post : m
    })

    // Parse the `to` key. URLSearchParams handles '+', percent-decoding, and
    // values containing '='; it never throws on a malformed escape (unlike a
    // bare decodeURIComponent), so a garbage query degrades to the fallback
    // landing rather than an uncaught exception that leaves the 404 visible.
    var key = ''
    if (typeof URLSearchParams !== 'undefined') {
      key = new URLSearchParams(search || '').get('to') || ''
    } else {
      // Fallback for very old engines without URLSearchParams (e.g. IE).
      var params = (search || '').replace(/^\?/, '').split('&')
      for (var i = 0; i < params.length; i++) {
        var eq = params[i].indexOf('=')
        if (params[i].slice(0, eq === -1 ? params[i].length : eq) === 'to') {
          var raw = (eq === -1 ? '' : params[i].slice(eq + 1)).replace(/\+/g, ' ')
          try { key = decodeURIComponent(raw) } catch (e) { key = raw }
          break
        }
      }
    }

    var target = Object.prototype.hasOwnProperty.call(MAPPING, key)
      ? MAPPING[key]
      : fallbackFor(key)

    return versionRoot + target
  }

  // Export for the browser (auto-redirect) and for tests (Node/CommonJS).
  if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
      resolveGoPhp: resolveGoPhp,
      MAPPING: MAPPING,
      fallbackFor: fallbackFor,
      PUBLISHED_VERSIONS: PUBLISHED_VERSIONS
    }
  } else if (root && root.location) {
    var to = resolveGoPhp(root.location.pathname, root.location.search)
    if (to) root.location.replace(to)
  }
})(typeof window !== 'undefined' ? window : this)
