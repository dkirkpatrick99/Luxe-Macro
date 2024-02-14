// swift-tools-version: 5.9

import CompilerPluginSupport
import PackageDescription

#if !os(Linux)
  let realm: [Package.Dependency] = [
    .package(url: "https://github.com/realm/realm-swift.git", from: "10.42.3"),
  ]
  let realmTarget: [Target.Dependency] = [
    .product(name: "RealmSwift", package: "realm-swift"),
  ]
#else /* !os(Linux) */
  let realm: [Package.Dependency] = []
  let realmTarget: [Target.Dependency] = []
#endif /* os(Linux) */

let package = Package(
  name: "Mongo",
  platforms: [
    .macOS(.v13),
    .iOS(.v16),
    .tvOS(.v12),
    .visionOS(.v1),
    .watchOS(.v4),
  ],
  products: [
    .library(
      name: "Mongo",
      targets: ["Mongo"]
    ),
    .executable(
      name: "MongoMacrosClient",
      targets: ["MongoMacrosClient"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/vapor/vapor.git", from: "4.84.1"),
    .package(url: "https://github.com/vapor/fluent.git", from: "4.8.0"),
    .package(url: "https://github.com/CasaPerks/fluent-mongo-driver.git", from: "4.0.3"),
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.2.0"),
    .package(url: "https://github.com/nicklockwood/SwiftFormat", from: "0.51.15"),
    .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
  ] + realm,
  targets: [
    .macro(
      name: "MongoMacros",
      dependencies: [
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
      ]
    ),
    .target(name: "Mongo",
            dependencies: [
              .product(name: "Vapor", package: "vapor"),
              .product(name: "Fluent", package: "fluent"),
              .product(name: "FluentMongoDriver", package: "fluent-mongo-driver"),
              .target(name: "MongoMacros"),
            ] + realmTarget),

    .executableTarget(name: "MongoMacrosClient", dependencies: [
      .target(name: "Mongo"),
    ]),

    .testTarget(
      name: "MongoTests",
      dependencies: [
        .target(name: "MongoMacros"),
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
      ]
    ),
  ]
)
