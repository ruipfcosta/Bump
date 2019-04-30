import Foundation

enum BumpfileParserError: String, LocalizedError {
    case bumpfileNotFound = "Bumpfile not found"
    
    var errorDescription: String? {
        return rawValue
    }
}

class BumpfileParser {
    private let bumpFilename = "Bumpfile"
    
    func parse() throws -> [[String]] {
        
        // Make sure the Bumpfile exists
        guard FileManager.default.fileExists(atPath: bumpFilename) else {
            throw BumpfileParserError.bumpfileNotFound
        }
        
        // Parse entries from Bumpfile
        let contents = try String(contentsOfFile: bumpFilename, encoding: .utf8)
        let entries = contents.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.hasPrefix("#") }
            .filter { !$0.isEmpty }
        
        // Parse the parts that make each entry
        return entries.map(parseEntries)
    }
    
    private func parseEntries(line: String) -> [String] {
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
        
        // Save remaining characters
        if let t = parsedToken {
            parts.append(t)
        }
        
        return parts
    }
}
