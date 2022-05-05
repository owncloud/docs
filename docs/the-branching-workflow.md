# The Branching Workflow

The Docs repo itself is not versioned as it assembles other doc repos and other doc repos might use versioning. For any repo that uses versioning, changes in that repo must be made in master and backported to the corresponding branch if applicable. Usually only 2 working branches and master named `next` are maintained. Any documentation that is versioned can use `latest` in the URL instead of a branch number which points automatically to the latest stable branch of the corresponding documentation.

See the "Create a New Version Branch documentation" link in each doc repo readme at the bottom for details how to do versioning if applicable.
