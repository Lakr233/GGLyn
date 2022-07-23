// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GCDWebServer",
    products: [
        .library(
            name: "GCDWebServer",
            targets: ["GCDWebServer"]
        ),
    ],
    targets: [
        .target(
            name: "GCDWebServer",
            dependencies: [],
            path: ".",
            exclude: [
                "Package.swift",
                "LICENSE",
            ],
            resources: [
                .copy("GCDWebUploader/GCDWebUploader.bundle"),
            ],
            cSettings: [
                .headerSearchPath("GCDWebServer/Core"),
                .headerSearchPath("GCDWebServer/Requests"),
                .headerSearchPath("GCDWebServer/Responses"),
            ]
        ),
    ]
)
