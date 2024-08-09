//
//  Created by Kumpels and Friends on 09.01.23.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation
import PackagePlugin

@main struct SwiftGenPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        let genSourcesDir = context.pluginWorkDirectory.appending("GeneratedSources")
        try FileManager.default.createDirectory(atPath: genSourcesDir.string, withIntermediateDirectories: true)

        return [
            stringCommand(for: target, genSourcesDir: genSourcesDir, context: context),
            assetCommand(for: target, genSourcesDir: genSourcesDir, context: context)
        ].compactMap { $0 }
    }

    func stringCommand(for target: Target, genSourcesDir: Path, context: PluginContext) -> Command? {
        // swiftgen run strings Resources/en.lproj -n structured-swift5 --param publicAccess
        let path = target.directory.appending(subpath: "Resources/en.lproj")
        guard FileManager.default.fileExists(atPath: path.string) else { return nil }

        let directory = context.package.directory
        guard (try? FileManager.default.paths(in: path, with: ["strings", "stringsDict"])) != nil else { return nil }
        let output = genSourcesDir.appending(subpath: "Strings+Generated.swift")
//        if FileManager.default.fileExists(atPath: output.string) {
//            return nil
//        }
        return .prebuildCommand(
            displayName: "Running SwiftGen string generation command",
            executable: directory.appending("swiftgen"),
            arguments: [
                "run",
                "strings",
                path,
                "-n", "structured-swift5",
                "--param", "publicAccess",
                "--output", "\(output)"
            ],
            environment: [:],
            outputFilesDirectory: genSourcesDir
//            inputFiles: input,
//            outputFiles: [
//                output
//            ]
        )
    }

    func assetCommand(for target: Target, genSourcesDir: Path, context: PluginContext) -> Command? {
        // swiftgen run xcassets Sources/Styling/Resources/Media.xcassets --templatePath swift5-swiftui.stencil --param
        // forceProvidesNamespaces --param publicAccess
        guard
            let paths = try? FileManager.default.paths(
                in: target.directory.appending(subpath: "Resources"),
                with: ["xcassets"]
            ),
            paths.allSatisfy({ FileManager.default.fileExists(atPath: $0.string) })
        else { return nil }

        let directory = context.package.directory
        let output = genSourcesDir.appending(subpath: "XCAssets+Generated.swift")
        if FileManager.default.fileExists(atPath: output.string) {
            try? FileManager.default.removeItem(atPath: output.string)
        }
        return .prebuildCommand(
            displayName: "Running SwiftGen xcassets generation command",
            executable: directory.appending("swiftgen"),
            arguments: [
                "run",
                "xcassets",
                "--templatePath", "\(context.package.directory)/swift5-swiftui.stencil",
                "--param", "forceProvidesNamespaces",
                "--param", "publicAccess",
                "--output", "\(output)"
            ] + paths.map { $0.string },
            environment: [:],
            outputFilesDirectory: genSourcesDir
        )
    }
}

extension FileManager {
    func paths(in folder: Path, with pathExtensions: Set<String>) throws -> [Path] {
        try contentsOfDirectory(
            at: URL(fileURLWithPath: folder.string),
            includingPropertiesForKeys: nil
        ).filter { pathExtensions.contains($0.pathExtension) }.map { Path($0.standardizedFileURL.path) }
    }
}
