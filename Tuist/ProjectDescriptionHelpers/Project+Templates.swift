import ProjectDescription

public enum FeatureTarget {
    case framework
    case tests
}

public extension Target {
    /// Helper function to create the application, unit test, and ui test targets.
    static func makeAppTargets(
        name: String,
        platform: Platform = .iOS,
        dependencies: [TargetDependency]
    ) -> [Target] {
        let platform: Platform = platform
        let infoPlist: [String: InfoPlist.Value] = [
            "CFBundleShortVersionString": "1.0",
            "CFBundleVersion": "1",
            "UIMainStoryboardFile": "",
            "UILaunchStoryboardName": "LaunchScreen"
        ]

        let mainTarget = Target(
            name: name,
            platform: platform,
            product: .app,
            bundleId: "io.tuist.\(name)",
            infoPlist: .extendingDefault(with: infoPlist),
            sources: ["Targets/\(name)/Sources/**"],
            resources: ["Targets/\(name)/Resources/**"],
            dependencies: dependencies
        )

        let testTarget = Target(
            name: "\(name)Tests",
            platform: platform,
            product: .unitTests,
            bundleId: "io.tuist.\(name)Tests",
            infoPlist: .default,
            sources: ["Targets/\(name)/Tests/**"],
            dependencies: [
                .target(name: "\(name)"),
                .xctest
            ])

        let uiTestTarget = Target(
            name: "\(name)UITests",
            platform: platform,
            product: .uiTests,
            bundleId: "io.tuist.\(name)UITests",
            infoPlist: .default,
            sources: ["Targets/\(name)/UITests/**"],
            dependencies: [
                .target(name: "\(name)"),
                .xctest
            ])
        return [mainTarget, testTarget, uiTestTarget]
    }

    /// Helper function to create a framework target and an associated unit test target.
    static func makeFrameworkTargets(
        name: String,
        dependencies: [String] = [],
        externalDependencies: [String] = [],
        testDependencies: [String] = [],
        targets: Set<FeatureTarget> = Set([.framework, .tests]),
        platform: Platform = .iOS
    ) -> [Target] {

        // Configurations

        // Test dependencies
        var targetTestDependencies: [TargetDependency] = [
            .target(name: "\(name)"),
            .xctest
        ] + testDependencies.map({ .target(name: $0) })

        // Target dependencies
        var targetDependencies: [TargetDependency] = dependencies.map { .target(name: $0) }

        targetDependencies.append(contentsOf: externalDependencies.map { .package(product: $0) })

        // Targets
        var projectTargets: [Target] = []
        if targets.contains(.framework) {
            projectTargets.append(Target(
                name: name,
                platform: platform,
                product: .framework,
                bundleId: "io.tuist.\(name)",
                infoPlist: .default,
                sources: ["Targets/\(name)/Sources/**"],
                resources: [],
                dependencies: targetDependencies
            ))
        }

        if targets.contains(.tests) {
            projectTargets.append(Target(
                name: "\(name)Tests",
                platform: platform,
                product: .unitTests,
                bundleId: "io.tuist.\(name)Tests",
                infoPlist: .default,
                sources: ["Targets/\(name)/Tests/**"],
                resources: [],
                dependencies: targetTestDependencies
            ))
        }

        return projectTargets
    }
}

