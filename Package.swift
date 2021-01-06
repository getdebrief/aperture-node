// swift-tools-version:5.2
import PackageDescription

let package = Package(
  name: "ApertureCLI",
  platforms: [
    .macOS(.v10_12)
  ],
  products: [
    .executable(
      name: "aperture",
      targets: [
        "ApertureCLI"
      ]
    )
  ],
  dependencies: [
    .package(url: "https://github.com/getdebrief/Aperture", from: "0.4.1")
  ],
  targets: [
    .target(
      name: "ApertureCLI",
      dependencies: [
        "Aperture"
      ]
    )
  ]
)
