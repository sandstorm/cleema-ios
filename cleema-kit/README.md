# cleema-kit

Modules for the Cleema iOS app.

### Things to notice
- All resources (strings, asset catalogs etc.) must be located under <ModuleName>/Resources and a resources declaration must be added to its target in the Package.swift manifest:
```swift
    .target(
        name: <TargetName>,
            dependencies: [
            // ...
              ],
            resources: [.process("Resources")]
        ),
```
