// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MindBloom",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "MindBloom",
            path: "Sources"
        )
    ]
)
