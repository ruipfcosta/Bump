import Foundation

enum VersionUpdaterError: Error {
    case unrecognizedWildcardType
    case mismatchingDataType
    case invalidDateFormat
}

class VersionUpdater {
    private enum VersionPart {
        case text(value: String)
        case digitWildcard
        case dateWildcard(format: String)
    }
    
    private let formatParts: [VersionPart]

    init(format: String) throws {
        var tokens: [VersionPart] = []
        let scanner = Scanner(string: format)
        var token: NSString?
        
        while !scanner.isAtEnd {
            token = .none
            scanner.scanUpTo("*[", into: &token)
            
            if let t = token {
                if !scanner.isAtEnd {
                    scanner.scanString("*[", into: .none)
                }
                tokens.append(.text(value: String(t)))
            }
            
            token = .none
            scanner.scanUpTo("]", into: &token)
            if !scanner.isAtEnd {
                scanner.scanString("]", into: .none)
            }
            
            if let t = token {
                // Identify wildcard type
                if t.hasPrefix("digit") {
                    tokens.append(.digitWildcard)
                } else if t.hasPrefix("date:") {
                    let format = t.replacingOccurrences(of: "date:", with: "")
                    tokens.append(.dateWildcard(format: format))
                } else {
                    throw VersionUpdaterError.unrecognizedWildcardType
                }
            }
        }
        
        self.formatParts = tokens
    }

    func nextVersion(_ currentVersion: String) throws -> String? {
        var updatableParts = 0
        
        let pattern = formatParts.reduce("") { acc, part in
            switch part {
            case .text(value: let text):
                return acc.appending(text)
            case .digitWildcard:
                updatableParts += 1
                return acc.appending("(\\d+)")
            case .dateWildcard:
                updatableParts += 1
                return acc.appending("(.+)")
            }
        }
        
        let matchingGroups = currentVersion.capturedGroups(withRegex: pattern)
        
        // Make sure the pattern built captures the same number of updatable parts
        guard updatableParts == matchingGroups.count else { return .none }
        
        // Build new version
        var updateIndex = 0
        
        do {
            let newVersion = try formatParts.reduce("") { acc, part in
                switch part {
                case .text(value: let text):
                    return acc.appending(text)
                case .digitWildcard:
                    guard let currentDigit = Int(matchingGroups[updateIndex]) else {
                        throw VersionUpdaterError.mismatchingDataType
                    }
                    
                    updateIndex += 1
                    return acc.appending("\(currentDigit + 1)")
                case .dateWildcard(let format):
                    let formattter = DateFormatter()
                    formattter.dateFormat = format
                    
                    let dateString = formattter.string(from: Date())
                    
                    guard !dateString.isEmpty else {
                        throw VersionUpdaterError.invalidDateFormat
                    }
                    
                    updateIndex += 1
                    return acc.appending(dateString)
                }
            }
            
            return newVersion
        } catch {
            throw error
        }
    }
}
