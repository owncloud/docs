# The Branching Workflow

In addition to the `master` branch, each documentation repository will have two branches at any one time; one for the current version of the software and one for the previous version.

For example, the current release of ownCloud core is 10.1, and the previous version is 10.0, so it has three branches: `master`, `10.1`, and  `10.0`.

This approach aims to do two things:

- **Document the major _and minor_ release versions.** Doing so should make it easier for systems administrators, as well as ownCloud administrators and users, to maintain and use their ownCloud installations because they can use the documentation targetted at their installation's major and minor release.
- **Reduce the documentation maintenance overhead.** If the documentation for each version only covered the major release, then it would invariably need minor — _and optionally patch_ — specific additions, to cover _new_, _deprecated_, and _changed features_. While doing this, initially, would not incur too much overhead, over time it would become a maintenance nightmare.

This approach will initially require greater effort from the contributors and maintainers.
This is because each feature branch, which is typically branched from and merged back to master, also needs to be backported to at least one of the version-specific branches — _if not two_.
However, if PRs are small enough, then this shouldn't be too much work.

In the not-too-distant future, a script will be developed to automate as much of this as possible.
When it's complete, it will be documented here.
