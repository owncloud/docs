# Environment variables needed to generate the search index are only provided here in the docs repo in .drone.star
# Also see the documentation for more details.

def main(ctx):
    # Config

    # There is only one branch to be deployed
    deployment_branch = "master"

    return [
        checkStarlark(),
        build(ctx, deployment_branch),
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

def build(ctx, deployment_branch):
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
                    "endpoint": from_secret("cache_s3_server"),
                    "access_key": from_secret("cache_s3_access_key"),
                    "secret_key": from_secret("cache_s3_secret_key"),
                    "restore": "true",
                },
            },
            {
                "name": "docs-build",
                "pull": "always",
                "image": "owncloudci/nodejs:18",
                "environment": {
                    "UPDATE_SEARCH_INDEX": ctx.build.branch == deployment_branch,
                    "ELASTICSEARCH_NODE": from_secret("elasticsearch_node"),
                    "ELASTICSEARCH_INDEX": from_secret("elasticsearch_index"),
                    "ELASTICSEARCH_READ_AUTH": from_secret("elasticsearch_read_auth"),
                    "ELASTICSEARCH_WRITE_AUTH": from_secret("elasticsearch_write_auth"),
                },
                "commands": [
                    # the build attribute is only necessary for the docs-server repo
                    #"yarn antora --attribute format=html",
                    "npx antora --stacktrace --cache-dir cache --redirect-facility static --clean --fetch site.yml",
                    "bin/optimize_crawl -x",
                ],
            },
            {
                "name": "upload-html",
                "pull": "always",
                "image": "plugins/s3-sync",
                "settings": {
                    "bucket": "uploads",
                    "endpoint": from_secret("docs_s3_server"),
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
                    "webhook": from_secret("rocketchat_talk_webhook"),
                    "channel": "builds",
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
                    "refs/tags/**",
                    "refs/pull/**",
                ],
            },
        },
    }

def from_secret(name):
    return {
        "from_secret": name,
    }
