def main(ctx):
    # Config

    # Version shown as latest in generated documentations
    # It's fine that this is out of date in version branches, usually just needs
    # adjustment in master/deployment_branch when a new version is added to site.yml
    latest_version = "10.4"

    # Current version branch (used to determine when changes are supposed to be pushed)
    # pushes to base_branch will trigger a build in deployment_branch but pushing
    # to fix-typo branch won't
    base_branch = latest_version

    # Version branches never deploy themselves, but instead trigger a deployment in deployment_branch
    # This must not be changed in version branches
    deployment_branch = "master"

    return [pipeline(ctx, latest_version, deployment_branch)]

def pipeline(ctx, latest_version, deployment_branch):
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
                    "yarn validate --pull",
                ],
            },
            {
                "name": "docs-build",
                "pull": "always",
                "image": "owncloudci/nodejs:11",
                "environment": {
                    "ELASTICSEARCH_HOST": from_secret("elasticsearch_host"),
                    "ELASTICSEARCH_INDEX": from_secret("elasticsearch_index"),
                    "ELASTICSEARCH_PORT": from_secret("elasticsearch_port"),
                    "ELASTICSEARCH_PROTO": from_secret("elasticsearch_proto"),
                    "ELASTICSEARCH_READ_AUTH": from_secret("elasticsearch_read_auth"),
                    "ELASTICSEARCH_WRITE_AUTH": from_secret("elasticsearch_write_auth"),
                    "latestVersion": latest_version,
                },
                "commands": [
                    "yarn antora --pull --attribute format=html",
                ],
            },
            {
                "name": "docs-pdf",
                "pull": "always",
                "image": "owncloudci/asciidoctor:latest",
                "commands": [
                    "bin/cli -m",
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
                    ],
                    "branch": [
                        deployment_branch,
                    ]
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
                    ],
                    "branch": [
                        deployment_branch,
                    ]
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
                    ],
                    "status": [
                        "failure",
                    ],
                },
            },
        ],
        "trigger": {
            "ref": [
                "refs/tags/**",
                "refs/pull/**",
                "refs/pull-requests/**",
                "refs/heads/**",
            ],
        },
    }

def from_secret(name):
    return {
        "from_secret": name,
    }
