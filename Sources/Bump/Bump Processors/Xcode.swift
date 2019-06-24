import Foundation
import XcodeProj

protocol BumpProcessor {
    func run(versionUpdater: VersionUpdater, remainingParts: [String]) throws
}

enum XcodeError: String, LocalizedError {
    case missingTargetNameParameter = "Missing target name"
    case projectFileNotFound = "xcodeproj file not found"
    case failedToLoadProject = "Failed to load xcodeproj file"
    case targetNotFoundInProject = "Target not present in project"
    case missingConfigurations = "No configurations found in project"
    case plistFilePathFileNotSet = "Info.plist path not found in confgurations"
    case failedToReadPlistFile = "Failed to read Info.plist"
    case failedToWritePlistFile = "Failed to write to Info.plist"
    
    var errorDescription: String? {
        return rawValue
    }
}

// Format: "xcode version target"
class Xcode: BumpProcessor {
    private let infoPlistPathKey = "INFOPLIST_FILE"
    private let versionPlistProperty = "CFBundleShortVersionString"
    
    func run(versionUpdater: VersionUpdater, remainingParts: [String]) throws {
        guard let targetName = remainingParts.first?.replacingOccurrences(of: "\"", with: "") else {
            throw XcodeError.missingTargetNameParameter
        }
        
        guard let projectFilename = findProjectFileName() else {
            throw XcodeError.projectFileNotFound
        }

        guard let project = readProjectFile(path: projectFilename) else {
            throw XcodeError.failedToLoadProject
        }
        
        guard let target = findTarget(project: project, targetName: targetName) else {
            print("Missing target \("targetName")!")
            throw XcodeError.targetNotFoundInProject
        }
        
        guard let configurationsList = target.buildConfigurationList?.buildConfigurations else {
            throw XcodeError.missingConfigurations
        }
        
        let plistPaths = configurationsList.compactMap { $0.buildSettings[infoPlistPathKey] as? String }
        
        guard plistPaths.count > 0 else {
            throw XcodeError.plistFilePathFileNotSet
        }
            
        // Remove duplicated info plist paths as multiple configurations will most likely refer to the same info plist
        let uniquePlistPaths = Set(plistPaths)
            
        for path in uniquePlistPaths {
            // Expand $(SRCROOT) if present
            let currentPath = FileManager.default.currentDirectoryPath
            let expandedPath = path.replacingOccurrences(of: "$(SRCROOT)", with: "\(currentPath)")
            
            print("Updating \"\(expandedPath)\" for target \"\(target.name)\"")
            
            do {
                try updateCurrentVersion(infoPlistPath: expandedPath, versionUpdater: versionUpdater)
            } catch {
                throw error
            }
        }
    }
    
    private func findProjectFileName() -> String? {
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: fileManager.currentDirectoryPath)
        
        while let file = enumerator?.nextObject() {
            if let type = enumerator?.fileAttributes?[.type] as? FileAttributeType {
                switch type {
                case .typeDirectory:
                    if let filename = file as? String, filename.hasSuffix(".xcodeproj") {
                        return filename
                    }
                default:
                    break
                }
            }
        }
        
        return nil
    }
    
    private func readProjectFile(path: String) -> XcodeProj? {
        return try? XcodeProj(pathString: path)
    }
    
    private func findTarget(project: XcodeProj, targetName: String) -> PBXNativeTarget? {
        return project.pbxproj.nativeTargets.first { $0.name == targetName }
    }
    
    private func updateCurrentVersion(infoPlistPath path: String, versionUpdater: VersionUpdater) throws {
        guard let infoPlistData = FileManager.default.contents(atPath: path) else {
            throw XcodeError.failedToReadPlistFile
        }
        
        // Read Info.plist contents
        var plistDicionary: [String : Any] = [:]
        
        do {
            guard let dictionary = try PropertyListSerialization.propertyList(from: infoPlistData, options: [], format: .none) as? [String : Any] else {
                throw XcodeError.failedToReadPlistFile
            }
            
            plistDicionary = dictionary
        } catch {
            throw XcodeError.failedToReadPlistFile
        }
        
        guard let currentVersion = plistDicionary[versionPlistProperty] as? String else {
            throw XcodeError.failedToReadPlistFile
        }
        
        // Update version
        let nextVersion: String
        
        do {
            nextVersion = try versionUpdater.nextVersion(currentVersion)
            plistDicionary[versionPlistProperty] = nextVersion
        } catch {
            throw error
        }
        
        // Write updated Info.plist contents
        do {
            let plistData = try PropertyListSerialization.data(fromPropertyList: plistDicionary, format: .xml, options: 0)
            try plistData.write(to: URL(fileURLWithPath: path))
        } catch {
            throw XcodeError.failedToWritePlistFile
        }
    }
}
