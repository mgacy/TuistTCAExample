import ProjectDescription
import ProjectDescriptionHelpers

func targets() -> [Target] {
    var targets: [Target] = []
    targets += Target.makeAppTargets(
        name: "TicTacToe",
        dependencies: [
            .target(name: "Common"),
            .target(name: "AppCore"),
            .target(name: "AuthenticationClient")
        ])
    targets += Target.makeFrameworkTargets(
        name: "Common",
        externalDependencies: ["ComposableArchitecture"])
    targets += Target.makeFrameworkTargets(
        name: "AppCore",
        dependencies:  ["Common", "AuthenticationClient", "Login", "NewGame"])
    targets += Target.makeFrameworkTargets(
        name: "AuthenticationClient",
        dependencies: ["Common"])
    targets += Target.makeFrameworkTargets(
        name: "Game",
        dependencies:  ["Common"])
    targets += Target.makeFrameworkTargets(
        name: "Login",
        dependencies:  ["Common", "AuthenticationClient", "TwoFactor"])
    targets += Target.makeFrameworkTargets(
        name: "NewGame",
        dependencies:  ["Common", "Game"])
    targets += Target.makeFrameworkTargets(
        name: "TwoFactor",
        dependencies:  ["Common", "AuthenticationClient"])
    return targets
}

let project = Project(
    name: "TicTacToe",
    organizationName: "com.mgacy",
    packages: [
        .remote(url: "https://github.com/pointfreeco/swift-composable-architecture", requirement: .upToNextMajor(from: "0.34.0"))
    ],
    targets: targets(),
    schemes: [],
    resourceSynthesizers: []
)
