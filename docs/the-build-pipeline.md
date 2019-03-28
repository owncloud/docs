# Build Pipeline and Web Deployment

ownCloud uses <a href="https://drone.io/">Drone</a> for building and deploying the documentation.
Drone is a [Continuous Delivery](https://www.continuousdelivery.com/) platform that helps optimize and automate software delivery.

The build pipeline is configured in [.drone.yml](https://github.com/owncloud/docs/blob/master/.drone.yml), located in the root directory of the docs repository.
You can view the current build status of the docs at https://drone.owncloud.com/owncloud/docs.

Every push to the docs master branch triggers a drone build. At the end of the build process, the docs are deployed to production.

It's outside the scope of this file to discuss the process or [the `.drone.yml` file format](https://0-8-0.docs.drone.io/) in-depth.
However, in essence, here is how the build pipeline works:

1. The docs repository is cloned.
2. All required dependencies are installed.
3. The documentation is validated.
4. The documentation is built.
5. The documentation PDF manuals are built.
6. The PDF manuals are deployed.
7. The HTML version of the documentation is deployed.
8. A build notification is sent.

## Build Notifications

Build notifications are sent to the `#documentation` channel in https://talk.owncloud.com when a build of the master, 10.0, and 10.1 branches fails.
Notifications are not sent for successful builds.

No Pull Request notifications are sent to the `#documentation` channel, as this information is visible within the Pull Request details.

If you're not already a member of the channel, please join, so that you know what's happening with the builds.
