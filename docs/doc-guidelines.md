# Documentation Guidelines

The focus of our documentation is to help users install, configure, run, enjoy, and upgrade ownCloud products, even troubleshoot if necessary. The target audience ranges from curious tech aficionados to experienced system administrators and beyond. Provide all relevant information, and do not assume a certain skill level or minimum knowledge.

It is important to know that proper documentation also helps developers in all stages of the development process and is early proof of how a potential user will see or interpret the outcome. The key to professional documentation is communication, testing, and proofreading. To achieve this, we've developed the following process, which naturally gets adjusted as we learn better ways to handle things.

Our documentation is hosted on GitHub in various repositories targeting different audiences. In the following description, we assume familiarity with GitHub and git commands. Text is written in AsciiDoc and generated via Antora. For further information on how to format your text, check out: https://asciidoctor.org/docs/asciidoc-recommended-practices/.

If you're new to writing or editing ownCloud documentation, we recommend the [Getting Started Guide](https://github.com/owncloud/docs/blob/master/docs/getting-started.md) and [Building the Documentation](https://github.com/owncloud/docs/blob/master/docs/build-the-docs.md) to get a good understanding of what awaits you. (Just don't let it discourage you!). Keep the [Best Practices Guide](https://github.com/owncloud/docs/blob/master/docs/best-practices.md) collection in mind.

To contribute to the documentation by providing content or fixing issues in the existing documentation:

- Clone the respective repository.
- Create a local branch.
- Edit an existing file or add a new one.

Before pushing the file to Github, please take care of the following:

1. Our documentation language is American English. If in doubt how things are written, consult a dictionary or use a spell-checker. If in doubt about your English language skills in general, request a language review from `@mmattel` or `@phil-davis` when you create a pull request on Github.
2. While writing or editing, please follow the [Style Guide](https://github.com/owncloud/docs/blob/master/docs/style-guide.md).
3. [Build the documentation](https://github.com/owncloud/docs/blob/master/docs/build-the-docs.md) and check the layout.

Commit all changed files and push the branch to GitHub.\
Now, log in to Github and find the branch you pushed, create a pull request and follow the rules below to make the process quick and easy for everyone:

1. **4 Eyes Principle (4EP)**

   Each pull request (PR) on Github must pass the 4EP. This means that each PR needs approval before merging into the master branch. Add technical reviewers for peer reviews or anyone else who can give you valuable feedback. The author and reviewers share the responsibility of driving the process forward. A reviewer should merge after approval if no more steps or reviews are needed. Otherwise, the reviewer should point out any next steps needed (e.g., backports), ask for more reviews or ask the author to take action (e.g., please merge after extra reviews or steps). Particularly if you don't want to take care of everything else in the approval and merge process, like backports, add one the following persons as reviewers: `@mmattel`, `@phil-davis`.

   Exceptions to the 4EP must be documented in the PR description and can be made if:

   1. Language violations require immediate action,
   2. The docs web site is not usable, partially or in full, without an emergency docs PR.

2. **Security and Dependency Bumps**

   These PRs are usually made by the bot but can also be created manually. SDB are related to the build process tools. The 4EP applies. The approver must take responsibility not to break the existing setup. Mandatory: add `@mmattel` or `@phil-davis` as reviewer.

3. **The main branch for changes is `master`**\
   Any changes start there. Exception:\
   Changes only apply to the branch the PR is made for, mandatory add a comment note.

4. **Technical and Process Changes**

   Technical and process changes are changes like prerequisites, installation, upgrades, API etc. They must first be tested by the author of the change, step by step, before documenting them.

5. **The PR title should summarize what the changes are about**

6. **Provide in the PR description the following information**\
   This gives reviewers a quick but thorough understanding of what they should be looking for.

   1. What changes or additions you made
   2. The positive impact of these changes if they aren't glaringly obvious
   3. Special notes like the wish for language proofing
   4. To which branches the PR needs to get backported (usually to the current release and the previous one for corrections to existing documentation)
   5. A link to the docs issue if one exists
   6. A link to the issue/PR in the corresponding repo this change will fix.

7. **Backporting**

   If backports are necessary, either use the documented backporting script which you can find in the `bin/` directory of the docs repo or do it manually and give the backport the following headline:

   1. [target branch] [source PR number] original headline\
     Example: `[10.15] [3456] Fix missing php library`

   2. As comment use `Backport of #3456` where 3456 is the source PR number.\
     This links the backport to the source PR. Set the label `backport`.

   3. The 4EP applies.

8. **Predefined Global Attributes**

  Attributes are like variables and will be replaced by the build process. Predefined global attributes are defined in either `site.yml`, the `global-attributes.yml` file in the docs repo and/or `antora.yml` which is located in the top level directory of your repository and affect all pages where this attribute is used. If an attribute exists for a case, use it. Read the [Best Practises Guide](https://github.com/owncloud/docs/blob/master/docs/best-practices.md#attributes) in the docs repo for more information on how to do that.

9. **Support Community Contributors**

  If one of the items listed above is missing in a contribution of a community member, add the relevant missing information. Leave a note of appreciation for the contributor and help with finalizing the PR.
