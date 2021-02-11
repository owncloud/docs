# The Branching Workflow

Only two branches are maintained at any one time; these are `master` and one for [the current ownCloud release].
Any change to the documentation is made in a branch based off of `master`.
Once the branch's PR is approved and merged, the PR is backported to the branch for the **current** ownCloud release if it applies to that release.

When a new ownCloud major or minor version is released, a new branch is created to track the changes for that release, and the branch for the previous release is no longer maintained.
That said, changes for patches and bugfixes to _some_ earlier versions are backported.

[the current ownCloud release]: https://github.com/owncloud/core/wiki/Maintenance-and-Release-Schedule
