// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Main",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .singleTargetLibrary("AppFeature"),
    ],
    dependencies: [
        .package(url: "https://github.com/realm/SwiftLint", exact: "0.52.3"),
    ],

    targets: {
        let appFeatureTarget = Target.target(
            name: "AppFeature",
            dependencies: [
                "SharedModels",
                "DataFeature",
                "HomeFeature"
            ]
        )
        
        let appFeatureTestsTarget =  Target.testTarget(
            name: "AppFeatureTests",
            dependencies: [
                "AppFeature"
            ]
        )
        
        let sharedModelsTarget = Target.target(
            name: "SharedModels",
            dependencies: []
        )
        
        let sharedModelsTestsTarget =  Target.testTarget(
            name: "SharedModelsTests",
            dependencies: [
                "SharedModels"
            ]
        )
        
        let homeFeatureTarget = Target.target(
            name: "HomeFeature",
            dependencies: [
                "SharedModels",
            ]
        )
        
        let homeFeatureTestsTarget =  Target.testTarget(
            name: "HomeFeatureTests",
            dependencies: [
                "HomeFeature"
            ]
        )
        
        let dataFeatureTarget = Target.target(
            name: "DataFeature",
            dependencies: [
                "SharedModels"
            ],
            resources: [
                .process("Resources")
            ]
        )
        
        let dataFeatureTestsTarget =  Target.testTarget(
            name: "DataFeatureTests",
            dependencies: [
                "DataFeature"
            ]
        )
        
        var targets: [Target] = [
            appFeatureTarget,
            appFeatureTestsTarget,
            sharedModelsTarget,
            sharedModelsTestsTarget,
            homeFeatureTarget,
            homeFeatureTestsTarget,
            dataFeatureTarget,
            dataFeatureTestsTarget
        ]
        
        return targets
    }()
)

// Inject base plugins into each target
package.targets = package.targets.map { target in
    var plugins = target.plugins ?? []
    plugins.append(.plugin(name: "SwiftLintPlugin", package: "SwiftLint"))
    target.plugins = plugins
    return target
}

extension Product {
    static func singleTargetLibrary(_ name: String) -> Product {
        .library(name: name, targets: [name])
    }
}
