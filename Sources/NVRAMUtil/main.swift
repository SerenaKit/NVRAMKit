// NVRAMUtilCLI
// A CLI Utility to demonstrate libNRVAMSwift

import Foundation
#if canImport(NVRAMKit)
import NVRAMKit
#endif

// Print the help message if the user used --help/-h or if no arguments were specified
if CMDLineSupport.shouldPrintHelpMessage || CMDLineSupport.CMDLineArgs.isEmpty {
    print(CMDLineSupport.helpMessage)
    exit(0)
}

let nvram = NVRAM()

/// Array of variables that the utility should set values for, ie test=testValue
let variablesToSet = CMDLineSupport.CMDLineArgs.filter() { $0.contains("=") }

// The following loop sets the NVRAM Variables to the specified values
// if any were given by the user
for variable in variablesToSet {
    // Divide the variable name given, and the variable value given
    let components = variable.components(separatedBy: "=")
    let variableName = components[0]
    let variableValue = components[1]
    do {
        try nvram.createOrSetOFVariable(variableName: variableName, variableValue: variableValue)
        try nvram.syncOFVariable(variableName: variableName, forceSync: false)
        print("\(variableName): \(variableValue)")
    } catch let error as NSError {
        print(error.localizedDescription)
        if let recoverySuggestion = error.localizedRecoverySuggestion {
            print("Recovery Suggestion: \(recoverySuggestion)")
        }
        
        exit(EXIT_FAILURE)
    }
}

func getAllNVRAMVariables() -> [String : String? ]{
    guard let dict = nvram.getAllOFVariables() else {
        fatalError("Couldn't get all NVRAM Variables. Sorry.")
    }
    return dict
}

for arg in CMDLineSupport.CMDLineArgs {
    switch arg {
    case "--all", "-a":
        let dict = getAllNVRAMVariables()
        let wrapped = dict.compactMapValues { $0 ?? "Unknown Value" }
        printFormatted(FromDict: wrapped)
        
    case "--list", "-l":
        let dict = getAllNVRAMVariables()
        print(dict.keys.joined(separator: "\n"))
        
    case "--print", "-p":
        let variableToPrint = CMDLineSupport.parseCMDLineArgument(longOpt: "--print", shortOpt: "-p", description: "NVRAM Variable to print")
        let value = nvram[variableName: variableToPrint]
        let dict = [variableToPrint : value ?? "Unknown Value"]
        printFormatted(FromDict: dict)
        
    case "--delete", "-d":
        let variableToDelete = CMDLineSupport.parseCMDLineArgument(longOpt: "--delete", shortOpt: "-d", description: "NVRAM Variable to delete")
        do {
            try nvram.deleteOFVariable(variableName: variableToDelete)
            print("Deleted NVRAM Variable \(variableToDelete)")
            
        } catch let error as NSError {
            print(error.localizedDescription)
            if let recoverySuggestion = error.localizedRecoverySuggestion {
                print("Recovery Suggestion: \(recoverySuggestion)")
            }
            
            exit(EXIT_FAILURE)
        }
    default:
        break
    }
}
