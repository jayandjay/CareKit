// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "CareKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v13), .watchOS(.v6)],
    products: [
        .library(
            name: "CareKit",
            targets: ["CareKit"]),

        .library(
            name: "CareKitUI",
            targets: ["CareKitUI"]),

        .library(
            name: "CareKitStore",
            targets: ["CareKitStore"]),
    ],
    targets: [
        .target(
            name: "CareKit",
            dependencies: ["CareKitUI", "CareKitStore"],
            path: "CareKit/CareKit",
            exclude: ["Info.plist"]),

        .target(
            name: "CareKitUI",
            path: "CareKitUI/CareKitUI",
            exclude: ["Info.plist"]),

        .target(
            name: "CareKitStore",
            path: "CareKitStore/CareKitStore",
            exclude: ["Info.plist"],
            resources: [
                .process("CoreData/Migrations/2_0To2_1/2.0_2.1_Mapping.xcmappingmodel")
            ]),

        .testTarget(
            name: "CareKitStoreTests",
            dependencies: ["CareKitStore"],
            path: "CareKitStore/CareKitStoreTests",
            exclude: ["Info.plist", "CareKitStore.xctestplan"],
            resources: [
                .process("CoreDataSchema/Migrations")
            ]),

        .testTarget(
            name: "CareKitTests",
            dependencies: ["CareKit"],
            path: "CareKit/CareKitTests",
            exclude: ["Info.plist"])
    ]
)

