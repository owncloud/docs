# Create a New Version Branch for Docs

When doing a new release of ownCloud Server like `10.x`, a new version branch must be created based on `master`. It is necessary to do this in four steps. Please set the new and former version numbers accordingly

**Step 1: This will create and configure the new `10.x` branch properly**

1.  Create a new `10.x` branch based on latest `origin/master`
2.  Copy the `.drone.star` file from the _former_ `10.x-1` branch
    (it contains the correct branch specific setup rules and replaces the current one coming from master)
3.  In `.drone.star` set `latest_version` to `10.x` (on top in section `def main(ctx)`)
4.  In `site.yml` have **only one** branch at `url: https://github.com/owncloud/docs.git`
    and set it to the **former** version of 10.x `10.x-1` ! (in section `content.sources.url.branches`)
5.  In `site.yml` adjust all `-version` keys according the new and former releases
    (in section `asciidoc.attributes`)
6.  In `antora.yml` change the version from `master` to `10.x`
7.  Run a build by entering `yarn antora`. No errors should occur
8.  Commit the changes and push the new `10.x` branch. DO NOT CREATE A PR!

**Step 2: This will configure the master branch properly to use the new `10.x` branch**

9.  Create new `changes_necessary_for_10.x` branch based on latest `origin/master`
10.  In `.drone.star` set `latest_version` to `10.x` (on top in section `def main(ctx)`)
11. In `site.yml` adjust the last **two** branches at `url: https://github.com/owncloud/docs.git` accordingly
    (in section `content.sources.url.branches`)
12. In `site.yml` adjust all `-version` keys according the new and former releases
    (in section `asciidoc.attributes`)
13. No changes in `antora.yml` but check if the version is set to `master`
14. Run a build by entering `yarn antora`. No errors should occur
15. Commit changes and push it
16. Create a Pull Request. When CI is green, all is done correctly. Merge the PR to master.

**Step 3: Protection and Renaming**

17. Go to the settings of the docs repository and change the protection of the branch list so that
    the `10.x` branch gets protected and the `10.x-2` branch is no longer protected.
18. Rename the `10.x-2` branch to `x_archived_10.x-2`

**Step 4: Set `latest` to 10.x**

19. Nothing needs to be done there. At the moment where the new release gets tagged - which is part of the release process - `latest` will be automatically set to the tagged release number. This works automatically up to version 10.20. Post that, backend-admins need to be informed to updated the process behind.
