import Foundation

func parseEntryParts(line: String) -> [String] {
    var parts: [String] = []
    var parsedToken: String?
    var quotedText: Bool = false

    for character in line {
        switch character {
        case " ":
            if quotedText {
                parsedToken?.append(character)
            } else {
                // Token parsing complete
                if let t = parsedToken {
                    parts.append(t)
                    parsedToken = .none
                }

                // Move to the next character
                continue
            }
        default:
            if parsedToken == .none {
                parsedToken = ""
            }

            switch character {
            case "\"":
                quotedText = !quotedText
                fallthrough
            default:
                parsedToken?.append(character)
            }
        }
    }

    // Saving remaining characters
    if let t = parsedToken {
        parts.append(t)
    }

    return parts
}

do {
    let bumpfilePath = "Bumpfile"

    // Make sure a Bumpfile exists
    guard FileManager.default.fileExists(atPath: bumpfilePath) else {
        print("Error: Couldn't find Bumpfile")
        exit(EXIT_FAILURE)
    }

    // Parse entries from Bumpfile
    let contents = try String(contentsOfFile: bumpfilePath, encoding: .utf8)
    let lines = contents.components(separatedBy: .newlines)
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.hasPrefix("#") }
        .filter { !$0.isEmpty }

    // Parse parts for each line
    let parts = lines.map(parseEntryParts)

    // Identify entries types and run using the correct processor
    parts.forEach {
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
    print("Error: Unable to parse Bumpfile")
    exit(EXIT_FAILURE)
}

