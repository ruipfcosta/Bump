import Foundation

protocol BumpProcessor {
    func run(versionUpdater: VersionUpdater, remainingParts: [String]) throws
}

// Format: "xcode version target"
class Xcode: BumpProcessor {
    func run(versionUpdater: VersionUpdater, remainingParts: [String]) throws {
        print("Xcode processor: \(remainingParts)")
    }
}
