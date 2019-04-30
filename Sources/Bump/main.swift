import Foundation

do {
    let entries = try BumpfileParser().parse()

    // Identify entries types and run using the correct processor
    entries.forEach {
        var remainingParts = $0
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

        // Initialize version updater
        do {
            let updater = try VersionUpdater(format: formatString)
            try processor.run(versionUpdater: updater, remainingParts: remainingParts)
        } catch {
            print("Error: \(error.localizedDescription)")
            exit(EXIT_FAILURE)
        }
    }

    exit(EXIT_SUCCESS)
} catch {
    exit(EXIT_FAILURE)
}

