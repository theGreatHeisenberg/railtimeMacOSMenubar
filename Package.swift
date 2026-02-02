// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CaltrainMenuBar",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "CaltrainMenuBar",
            targets: ["CaltrainMenuBar"]
        )
    ],
    targets: [
        .executableTarget(
            name: "CaltrainMenuBar",
            path: "CaltrainMenuBar",
            resources: [.process("stations.json")]
        )
    ]
)
