def main(ctx):
    # Config

    # Version shown as latest in generated documentations
    # It's fine that this is out of date in version branches, usually just needs
    # adjustment in master/deployment_branch when a new version is added to site.yml
    latest_version = "10.7"

    # Current version branch (used to determine when changes are supposed to be pushed)
    # pushes to base_branch will trigger a build in deployment_branch but pushing
    # to fix-typo branch won't
    base_branch = latest_version

    # Version branches never deploy themselves, but instead trigger a deployment in deployment_branch
    # This must not be changed in version branches
    deployment_branch = "master"

    return [
        build(ctx, latest_version, deployment_branch, base_branch),
        trigger(ctx, latest_version, deployment_branch, base_branch),
    ]

def build(ctx, latest_version, deployment_branch, base_branch):
    return {
        "kind": "pipeline",
        "type": "docker",
        "name": "documentation",
        "platform": {
            "os": "linux",
            "arch": "amd64",
        },
        "workspace": {
            "base": "/drone",
            "path": "src",
        },
        "steps": [
            {
                "name": "cache-restore",
                "pull": "always",
                "image": "plugins/s3-cache:1",
                "settings": {
                    "restore": "true",
                },
                "environment": {
                    "CACHE_S3_ACCESS_KEY": from_secret("cache_s3_access_key"),
                    "CACHE_S3_ENDPOINT": from_secret("cache_s3_endpoint"),
                    "CACHE_S3_SECRET_KEY": from_secret("cache_s3_secret_key"),
                },
            },
            {
                "name": "docs-deps",
                "pull": "always",
                "image": "owncloudci/nodejs:11",
                "commands": [
                    "yarn install",
                ],
            },
            {
                "name": "docs-validate",
                "pull": "always",
                "image": "owncloudci/nodejs:11",
                "commands": [
                    "yarn validate --fetch",
                ],
            },
            {
                "name": "docs-build",
                "pull": "always",
                "image": "owncloudci/nodejs:11",
                "environment": {
                    "BUILD_SEARCH_INDEX": "true",
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
                    "mount": [
                        "node_modules",
                    ],
                    "rebuild": "true",
                },
                "environment": {
                    "CACHE_S3_ACCESS_KEY": from_secret("cache_s3_access_key"),
                    "CACHE_S3_ENDPOINT": from_secret("cache_s3_endpoint"),
                    "CACHE_S3_SECRET_KEY": from_secret("cache_s3_secret_key"),
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
                    "flush": "true",
                    "flush_age": "14",
                },
                "environment": {
                    "CACHE_S3_ACCESS_KEY": from_secret("cache_s3_access_key"),
                    "CACHE_S3_ENDPOINT": from_secret("cache_s3_endpoint"),
                    "CACHE_S3_SECRET_KEY": from_secret("cache_s3_secret_key"),
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
                "image": "plugins/s3-sync:1",
                "settings": {
                    "bucket": "uploads",
                    "endpoint": "https://doc.owncloud.com",
                    "path_style": "true",
                    "source": "build/",
                    "target": "/deploy",
                },
                "environment": {
                    "AWS_ACCESS_KEY_ID": from_secret("aws_access_key_id"),
                    "AWS_SECRET_ACCESS_KEY": from_secret("aws_secret_access_key"),
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
                "name": "upload-html",
                "pull": "always",
                "image": "plugins/s3-sync:1",
                "settings": {
                    "bucket": "uploads",
                    "endpoint": "https://doc.owncloud.com",
                    "path_style": "true",
                    "source": "public/",
                    "target": "/deploy",
                },
                "environment": {
                    "AWS_ACCESS_KEY_ID": from_secret("aws_access_key_id"),
                    "AWS_SECRET_ACCESS_KEY": from_secret("aws_secret_access_key"),
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
                    "channel": "documentation",
                },
                "environment": {
                    "SLACK_WEBHOOK": from_secret("slack_webhook"),
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
        "trigger": {
            "ref": {
                "include": [
                    "refs/pull/**",
                    "refs/pull-requests/**",
                    "refs/heads/" + deployment_branch,
                ],
                "exclude": [
                    "refs/heads/" + base_branch,
                ],
            },
        },
    }

def trigger(ctx, latest_version, deployment_branch, base_branch):
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
                "name": "trigger-" + deployment_branch,
                "pull": "always",
                "image": "plugins/downstream",
                "settings": {
                    "server": "https://drone.owncloud.com",
                    "token": from_secret("drone_token"),
                    "fork": "true",
                    "repositories": [
                        "owncloud/docs@" + deployment_branch,
                    ],
                },
            },
        ],
        "trigger": {
            "ref": [
                "refs/heads/" + base_branch,
            ],
        },
    }

def from_secret(name):
    return {
        "from_secret": name,
    }
