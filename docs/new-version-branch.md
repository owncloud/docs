# Create a New Version Branch for Docs

When doing a new release of ownCloud Server like `10.x`, a new version branch must be created based on `master`. It is necessary to do this in steps. Please set the new and former version numbers accordingly. Keep in mind that we only process master and the latest two versions. For older versions we only keep the pdf files statically.

**Step 1: This will create and configure the new `10.x` branch properly**

1.  Create a new `10.x` branch based on latest `origin/master`
2.  Copy the `.drone.star` file from the _former_ `10.x-1` branch
    (it contains the correct branch specific setup rules and replaces the current one coming from master)
3.  In `.drone.star` set `latest_version` to `10.x` (on top in section `def main(ctx)`)
4.  In `site.yml` have **only one** branch at `url: https://github.com/owncloud/docs.git`
    and set it to the **former** version of 10.x `10.x-1` ! (in section `content.sources.url.branches`). Note, this step is only necessary for the docs repo, but not for the sub repos which are included (like docs-client-desktop).
5.  In `site.yml`, in section `asciidoc.attributes`, adjust all `-version` keys according the new and former releases
6.  In `antora.yml` change the version from `next` to `10.x`
7.  In `antora.yml`, in section `asciidoc.attributes`, adjust all version dependent keys if exists
8.  Edit the `modules/ROOT/pages/releases.adoc` file and manually add/link the pdf files from the former `10.x-2` branch to the `Older ownCloud Server Releases` section
9.  Run a build by entering `yarn antora`. No build errors should occur
10. Commit the changes and push the new `10.x` branch. DO NOT CREATE A PR!

**Step 2: This will configure the master branch properly to use the new `10.x` branch**

11.  Create new `changes_necessary_for_10.x` branch based on latest `origin/master`
12.  In `.drone.star` set `latest_version` to `10.x` (on top in section `def main(ctx)`)
13. In `site.yml` adjust the last **two** branches at `url: https://github.com/owncloud/docs.git` accordingly
   (in section `content.sources.url.branches`). Note, this step is only necessary for the docs repo, but not for the sub repos which are included (like docs-client-desktop).
14. In `site.yml` in section `asciidoc.attributes`, adjust all `-version` keys according the new and former releases
15. In `antora.yml`, check if the version is set to `next` and adjust all version dependent keys if exists
16. Edit the `modules/ROOT/pages/releases.adoc` file and manually add/link the pdf files from the former `10.x-2` branch to the `Older ownCloud Server Releases` section (you can copy the changes made from step 1)
17. Run a build by entering `yarn antora`. No build errors should occur
18. Commit changes and push it
19. Create a Pull Request. When CI is green, all is done correctly. Merge the PR to master.

**Step 3: Protection and Renaming**

20. Go to the settings of the docs repository and change the protection of the branch list so that
    the `10.x` branch gets protected and the `10.x-2` branch is no longer protected.
21. Rename the `10.x-2` branch to `x_archived_10.x-2`

**Step 4: Set `latest` to 10.x**

22. Nothing needs to be done there. At the moment where the new server release gets tagged - which is part of the release process - `latest` will be automatically set to the tagged release number. This works automatically up to version 10.20. Post that, backend-admins need to be informed to updated the process behind.
