# Cleema iOS app

# TOC

- [Cleema iOS app](#cleema-ios-app)
- [TOC](#toc)
    - [Setting things up](#setting-things-up)
    - [Deployments](#deployments)
        - [Deploy a new version to Testflight](#deploy-a-new-version-to-testflight)
        - [Release version](#release-version)
    - [Automatic SwiftFormat on pre commit](#automatic-swiftformat-on-pre-commit)
    - [Launch arguments for debugging](#launch-arguments-for-debugging)

## Setting things up

1. Run the following commands in your Terminal:
```
bundle install
brew bundle
```

2. Create a `.env` File at project root  and add all missing information (see `example.env` file)

> To access your local backend, go into the cleema-filament-backend `.env`-file and add the API Token at the bottom to IOS_LOCAL_ACCESS_TOKEN.
Then go to `Cleema/Boundaries/APIClient+Extensions`and change the `cleemaAPIBaseURL` to `http://localhost:8080`.
> The backend repository can be found [here](https://gitlab.sandstorm.de/cleema-app/cleema-filament-backend).
> **IMPORTANT**: If you don't use the local backend all of your interactions will use the real production cleema backend!

3. Start xcode
4. Make sure that you have selected "cleema-development" and an iOS-simulator inside the bar at the top of xcode, then
   press the build/run button. The project should be built and started inside the simulator

### Potential Errors and their fixes:
#### Missing Package Product
- go to the Cleema Project > Package Dependencies
- click on the '+' to add dependencies
- click on "Add Local..." and select the "cleema-kit" directory
- when seeing an error, add anyway
- now you see all package products to add and have to set every target for every package product to "Cleema"


## Deployments

Our deployments are done using our gitlab-ci and fastlane on our Mac-CI-Server (which stands inside our office).

To get a general overview over the fastlane/match setup (certificate handling etc.), please have a look at [this
document](https://gitlab.sandstorm.de/solarwatt/solarwatt-home-app-flutter/-/blob/main/notes/2022_11_22_App_FastlaneSetup.md)

> **NOTE**: There is one notable difference in our setup, we don't use an existing Apple-Connect-Api-Key. Instead we
> created a custom key for the cleema app.

### Deploy a new version to Testflight

1. Change the `MARKETING_VERSION` in `Cleema.xcodeproj/project.pbxproj` according to [semver](https://semver.org/). (You
   can also do this, by changing the version on the cleema target in xcode)
2. Commit and push the change.
3. Manually run the deployment gitlab-ci job
4. To publish the new version to testers, head over to [Testflight](https://appstoreconnect.apple.com) in your browser and login with our Apple ID 00 account
   (can be found in our bitwarden, you might need to ask someone to give you entry permissions - the 2fa-Key can be
   obtained from the music-iPad stored in our office)
5. Check that your build has been uploaded succesfully
6. On the testflight tab, go to internal/external testing and add the new build. All testers will automatically receive
   an invite for the build
7. To test the build on your mac, you can install the testflight app from the app store - make sure that you have an
   internal/external apple-account for testing and that it has been added to the available testers in testflight (in the
   browser, not the local app). You will receive an email invite on which you can click, which will open the avaialble build in your local Testflight app

### Release version

Follow the steps for [Deploy a new version to Testflight].
Make sure that the version you want to realease has been merged into main.
Create a [releaes](https://gitlab.sandstorm.de/cleema-app/cleema-ios/-/releases) with appropriate release notes.
Head over to [App Store Connect](https://appstoreconnect.apple.com) and publish the new build to the App Store from
Testflight.

> **NOTE**: Unfortunately we currently have to manually make sure that the new release is also created inside our
> repository, so we have a better idea what code has actually been deployed. In the future it might make sense to
> somehow interact with apple connects api, to read the latest release and automatically create the tag on our main
> branch... 

## Pipeline Monitoring

We receive slack messages inside the `#project-cleema-monitoring` for successful/failed builds of our apps/websites

## Automatic SwiftFormat on pre commit
- Install git-format-staged:
```
npm install --save-dev git-format-staged
```
- Install the pre commit hook
```shell
echo "git-format-staged --formatter \"swiftformat stdin --stdinpath '{}'\" '*/*.swift'" > .git/hooks/pre-commit
chmod a+x .git/hooks/pre-commit
```

## Launch arguments for debugging
- set ```wipeUser``` to ```YES``` to remove the currently logged in user
