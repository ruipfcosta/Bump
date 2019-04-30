import Foundation

do {
    let entries = try BumpfileParser().parse()

    // Identify entries types and run using the correct processor
    for entry in entries {
        var remainingParts = entry
        let identifier = remainingParts.removeFirst() // entry type
        let formatString = remainingParts.removeFirst() // version format

        let processor: BumpProcessor

        switch identifier {
        case "xcode":
            processor = Xcode()
        default:
            print("Error: Unrecognized identifier \"\(identifier)\"")
            exit(EXIT_FAILURE)
        }

        let updater = try VersionUpdater(format: formatString)
        try processor.run(versionUpdater: updater, remainingParts: remainingParts)
    }

    exit(EXIT_SUCCESS)
} catch {
    exit(EXIT_FAILURE)
}

