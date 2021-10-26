// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CompilationDatabaseGenerator",
    platforms: [.macOS(.v10_15)],
    products: [
        .executable(
            name: "CompilationDatabaseGenerator",
            targets: ["CompilationDatabaseGenerator"]
        ),
    ],
    targets: [
        .target(
            name: "CompilationDatabaseGenerator",
            dependencies: []
        ),
    ]
)
