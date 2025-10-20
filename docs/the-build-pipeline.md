# Build Pipeline and Web Deployment

ownCloud uses <a href="https://drone.io/">Drone</a> for building and deploying the documentation.
Drone is a [Continuous Delivery](https://www.continuousdelivery.com/) platform that helps optimize and automate software delivery.

The build pipeline is configured in [.drone.yml](https://github.com/owncloud/docs/blob/master/.drone.yml), located in the root directory of the docs repository. You can view the current build status of the docs at https://drone.owncloud.com/owncloud/docs.

Every push to the docs master branch triggers a drone build. At the end of the build process, the docs are deployed to production.

It's outside the scope of this file to discuss the process or [the `.drone.yml` file format](https://0-8-0.docs.drone.io/) in-depth.
However, in essence, here is how the build pipeline works:

1. The docs repository is cloned.
1. All required dependencies are installed.
1. All referenced content sources are added
1. The documentation is validated.
1. The documentation is built.
1. The HTML version of the documentation is deployed.
1. A build notification is sent.
