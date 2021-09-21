def main(ctx):
    # Config

    environment = "server"

    # Version shown as latest in generated documentations
    # It's fine that this is out of date in version branches, usually just needs
    # adjustment in master/deployment_branch when a new version is added to site.yml
    latest_version = "10.8"
    default_branch = "master"

    # Current version branch (used to determine when changes are supposed to be pushed)
    # pushes to base_branch will trigger a build in deployment_branch but pushing
    # to fix-typo branch won't
    base_branch = latest_version

    # Version branches never deploy themselves, but instead trigger a deployment in deployment_branch
    # This must not be changed in version branches
    deployment_branch = default_branch
    pdf_branch = default_branch

    return [
        checkStarlark(),
        build(ctx, environment, latest_version, deployment_branch, base_branch, pdf_branch),
        trigger(ctx, environment, latest_version, deployment_branch, base_branch, pdf_branch),
    ]

def checkStarlark():
    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "check-starlark",
        "steps": [
            {
                "name": "format-check-starlark",
                "image": "owncloudci/bazel-buildifier",
                "pull": "always",
                "commands": [
                    "buildifier --mode=check .drone.star",
                ],
            },
            {
                "name": "show-diff",
                "image": "owncloudci/bazel-buildifier",
                "pull": "always",
                "commands": [
                    "buildifier --mode=fix .drone.star",
                    "git diff",
                ],
                "when": {
                    "status": [
                        "failure",
                    ],
                },
            },
        ],
        "depends_on": [],
        "trigger": {
            "ref": [
                "refs/pull/**",
            ],
        },
    }

def build(ctx, environment, latest_version, deployment_branch, base_branch, pdf_branch):
    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "documentation",
        "platform": {
            "os": "linux",
            "arch": "amd64",
        },
        "steps": [
            {
                "name": "cache-restore",
                "pull": "always",
                "image": "plugins/s3-cache:1",
                "settings": {
                    "endpoint": from_secret("cache_s3_endpoint"),
                    "access_key": from_secret("cache_s3_access_key"),
                    "secret_key": from_secret("cache_s3_secret_key"),
                    "restore": "true",
                },
            },
            {
                "name": "docs-deps",
                "pull": "always",
                "image": "owncloudci/nodejs:14",
                "commands": [
                    "yarn install",
                ],
            },
            {
                "name": "docs-validate",
                "pull": "always",
                "image": "owncloudci/nodejs:14",
                "commands": [
                    "yarn validate --fetch",
                ],
            },
            {
                "name": "docs-build",
                "pull": "always",
                "image": "owncloudci/nodejs:14",
                "environment": {
                    "BUILD_SEARCH_INDEX": ctx.build.branch == deployment_branch,
                    "UPDATE_SEARCH_INDEX": ctx.build.branch == deployment_branch,
                    "ELASTICSEARCH_HOST": from_secret("elasticsearch_host"),
                    "ELASTICSEARCH_INDEX": from_secret("elasticsearch_index"),
                    "ELASTICSEARCH_PORT": from_secret("elasticsearch_port"),
                    "ELASTICSEARCH_PROTO": from_secret("elasticsearch_proto"),
                    "ELASTICSEARCH_READ_AUTH": from_secret("elasticsearch_read_auth"),
                    "ELASTICSEARCH_WRITE_AUTH": from_secret("elasticsearch_write_auth"),
                    "latestVersion": latest_version,
                },
                "commands": [
                    "yarn antora --fetch --attribute format=html",
                    "bin/optimize_crawl -x",
                ],
            },
            {
                "name": "docs-pdf",
                "pull": "always",
                "image": "owncloudci/asciidoctor:latest",
                "commands": [
                    "bin/makepdf -m",
                ],
            },
            {
                "name": "cache-rebuild",
                "pull": "always",
                "image": "plugins/s3-cache:1",
                "settings": {
                    "endpoint": from_secret("cache_s3_endpoint"),
                    "access_key": from_secret("cache_s3_access_key"),
                    "secret_key": from_secret("cache_s3_secret_key"),
                    "rebuild": "true",
                    "mount": [
                        "node_modules",
                    ],
                },
                "when": {
                    "event": [
                        "push",
                        "cron",
                    ],
                },
            },
            {
                "name": "cache-flush",
                "pull": "always",
                "image": "plugins/s3-cache:1",
                "settings": {
                    "endpoint": from_secret("cache_s3_endpoint"),
                    "access_key": from_secret("cache_s3_access_key"),
                    "secret_key": from_secret("cache_s3_secret_key"),
                    "flush": "true",
                    "flush_age": "14",
                },
                "when": {
                    "event": [
                        "push",
                        "cron",
                    ],
                },
            },
            {
                "name": "upload-pdf",
                "pull": "always",
                "image": "plugins/s3-sync",
                "settings": {
                    "bucket": "uploads",
                    "endpoint": "https://doc.owncloud.com",
                    "access_key": from_secret("docs_s3_access_key"),
                    "secret_key": from_secret("docs_s3_secret_key"),
                    "path_style": "true",
                    "source": "pdf_web/",
                    "target": "/pdf/%s" % environment,
                },
                "when": {
                    "event": [
                        "push",
                        "cron",
                    ],
                    "branch": [
                        pdf_branch,
                    ],
                },
            },
            {
                "name": "upload-html",
                "pull": "always",
                "image": "plugins/s3-sync",
                "settings": {
                    "bucket": "uploads",
                    "endpoint": "https://doc.owncloud.com",
                    "access_key": from_secret("docs_s3_access_key"),
                    "secret_key": from_secret("docs_s3_secret_key"),
                    "path_style": "true",
                    "source": "public/",
                    "target": "/deploy",
                    "delete": "true",
                },
                "when": {
                    "event": [
                        "push",
                        "cron",
                    ],
                    "branch": [
                        deployment_branch,
                    ],
                },
            },
            {
                "name": "notify",
                "pull": "if-not-exists",
                "image": "plugins/slack",
                "settings": {
                    "webhook": from_secret("slack_webhook_private"),
                    "channel": "documentation",
                },
                "when": {
                    "event": [
                        "push",
                        "cron",
                    ],
                    "status": [
                        "failure",
                    ],
                },
            },
        ],
        "depends_on": [
            "check-starlark",
        ],
        "trigger": {
            "ref": {
                "include": [
                    "refs/heads/%s" % deployment_branch,
                    "refs/heads/%s" % pdf_branch,
                    "refs/tags/**",
                    "refs/pull/**",
                ],
            },
        },
    }

def trigger(ctx, environment, latest_version, deployment_branch, base_branch, pdf_branch):
    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "trigger",
        "platform": {
            "os": "linux",
            "arch": "amd64",
        },
        "clone": {
            "disable": True,
        },
        "steps": [
            {
                "name": "trigger-%s" % deployment_branch,
                "pull": "always",
                "image": "plugins/downstream",
                "settings": {
                    "server": "https://drone.owncloud.com",
                    "token": from_secret("drone_token"),
                    "fork": "true",
                    "repositories": [
                        "owncloud/docs@%s" % deployment_branch,
                    ],
                },
            },
        ],
        "depends_on": [
            "documentation",
        ],
        "trigger": {
            "ref": [
                "refs/heads/%s" % base_branch,
            ],
        },
    }

def from_secret(name):
    return {
        "from_secret": name,
    }
