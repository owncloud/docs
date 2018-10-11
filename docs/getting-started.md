# Getting Started

This guide is here to help you get started with this repository, primarily if you've been contributing to the previous version of ownCloud's documentation, which used reStructuredText and Sphinx-Doc.

## Initial Steps

To contribute to the documentation, you first need to:

1. Learn [Antora's basics](./what-is-antora.md).
2. Learn [the AsciiDoc file format](./what-is-antora.md) basics.
3. Make sure you have [tools](./what-is-asciidoc.md#writing--editing-asciidoc-files) that can edit and preview AsciiDoc files.
4. Setup a [GitHub account](https://github.com/), if you haven't already.

## Setup Your Local Copy of the Docs Repository

With this done, you then need to get your local copy of the docs repository ready.
To do this, follow the following three steps.

1. Fork [the docs repository](https://github.com/owncloud/docs/blob/master/docs/).
   This is necessary, as you won't be able to push changes directly to the docs repository.

2. Clone the docs repository locally and enter it.

    ```console
    $ git clone git@github.com:owncloud/docs.git
    $ cd docs
    ```

3. Add a remote to your fork, by substituting your GitHub username in the command below.

    ```console
    $ git remote add {username} git@github.com:{username}/docs.git
    $ git fetch {username}
    ```

## Contributing to the Documentation

With that done, you're now ready to make regular contributions to the docs.
To do that, here are the steps to follow to contribute changes.

1. Create a local development branch off of `master` or another development branch and switch to it.
   You can do this in one command: `git checkout -b {branch-name}`.
   We recommend naming the branch such that you'll recognize its purpose; e.g., `deprecate-some-occ-command`, `document-firebase-database-support`.
2. Do some work, commit, repeat as necessary.
3. Push the branch to your remote fork of the docs repository.
4. Send a pull request from your fork to the docs repository.

Here's an example of contributing to the documentation

```console
$ git checkout -b deprecate-some-occ-command
Switched to a new branch 'deprecate-some-occ-command'

... do some work ...

$ git commit
... write your log message ...

$ git push {username} deprecate-some-occ-command:deprecate-some-occ-command
Counting objects: 38, done.
Delta compression using up to 2 threads.
Compression objects: 100% (18/18), done.
Writing objects: 100% (20/20), 8.19KiB, done.
Total 20 (delta 12), reused 0 (delta 0)
To ssh://git@github.com/{username}/docs.git
   b5583aa..4f51698  HEAD -> master
```

## Cleaning Up Your Branches After They're Merged

If you are a frequent contributor, you'll likely create a large number of branches, both locally and remotely.
To avoid confusing which ones are new and which are old, once your pull requests are merged into the master repository, we suggest removing the underlying branches.
Here’s how to do this.

### Local Branch Cleanup

```console
$ git branch -d <branchname>
```

### Remote Branch Removal

```console
$ git push {username} :<branchname>
```

**Note:** you can delete a remote branch through the GitHub UI.
