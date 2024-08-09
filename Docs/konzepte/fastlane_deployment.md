# Deployment Konzept

## Problem

The iOS-Cleema-App should be deployed to the Apple Store.
We want to make sure that all deployments are being published to Testflight, before they
are actullay being released to the public.
The whole process (apart from the release management inside Testflight) should be automated.

## Appetite

Very high - without automated releases we basically have no way to get our changes into the hands of our users.

## Solution

> We should probably take a look at how this is done for other customer apps we alreay have.

- [x] Check app store credentials and login
- [x] match setup
- [x] study fastlane docs fastlane setup (schauen, was bei match alles rausfaellt)
- [x] configure fastlane setup similar to sw project
- [x] gitlab-ci.yaml


## Rabbit-Holes

## No-Go's

- We only focus on automating the deployment for now, so automating tests is out of scope (though shouldn't be too hard
  implement, once the build can be automated)

