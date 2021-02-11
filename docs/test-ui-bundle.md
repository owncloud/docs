# Testing un-merged docs-ui changes

If you want to test an un-merged change made in the `docs-ui` repository with content from the ownCloud documentation, build the documentation as usual with the Antora command but add the option `--ui-bundle-url <path-to-your-local-ui-bundle>/ui-bundle.zip` to your command. The location for this bundle is in the `docs-ui` repository in directory `build/`. More details for prerequisites and how to create the `ui-bundle.zip` can be found in the [docs-ui](https://github.com/owncloud/docs-ui#owncloud-documentation-ui) repository.

The following example assumes:

- You are in the root directory of your local `docs` repository
- The `docs-ui` repository directory is on the same directory level as `docs`
- You have `ui-bundle.zip` manually created with [gulp pack](https://github.com/owncloud/docs-ui#preview-changes-using-owncloud-documentation)
- You have a webserver pointing to the `public` directory in your local `docs` repository to access the built documentation

```console
yarn antora \
	--ui-bundle-url ../docs/build/ui-bundle.zip \
	--url http://localhost:8080
```

If the build returns without an error, open the documentation with your browser to see your changes.
