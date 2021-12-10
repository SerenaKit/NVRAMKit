// NVRAMUtilCLI
// A CLI Utility to demonstrate libNRVAMSwift

import Foundation
#if canImport(libNVRAMSwift)
import libNVRAMSwift
#endif

// Print the help message if the user used --help/-h or if no arguments were specified
if CMDLineSupport.shouldPrintHelpMessage || CMDLineSupport.CMDLineArgs.isEmpty {
    print(CMDLineSupport.shouldPrintHelpMessage)
    exit(0)
}
let nvram = NVRAM()


/// Array of variables that the utility should set values for, ie test=testValue
let variablesToSet = CMDLineSupport.CMDLineArgs.filter() { $0.contains("=") }

for variable in variablesToSet {
    // Divide the variable name given, and the variable value given
    let components = variable.components(separatedBy: "=")
    let variableName = components[0]
    let variableValue = components[1]
    do {
        try nvram.createOrSetOFVariable(variableName: variableName, variableValue: variableValue)
        if !CMDLineSupport.shouldntSync {
            try nvram.syncOFVariable(variableName: variableName, forceSync: CMDLineSupport.shouldForceSync)
        }
    } catch {
        print(error.localizedDescription)
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
        for (key, value) in dict {
            print("\(key): \(value ?? "Unknown Value")")
        }
        
    case "--list", "-l":
        let dict = getAllNVRAMVariables()
        print(dict.keys.joined(separator: "\n"))
        
    case "--print", "-p":
        let variableToPrint = CMDLineSupport.parseCMDLineArgument(longOpt: "--print", shortOpt: "-p", description: "NVRAM Variable to print")
        let value = nvram.OFVariableValue(variableName: variableToPrint)
        print("\(variableToPrint): \(value ?? "Unknown Value")")
    case "--delete", "-d":
        let variableToDelete = CMDLineSupport.parseCMDLineArgument(longOpt: "--delete", shortOpt: "-d", description: "NVRAM Variable to delete")
        do {
            try nvram.deleteOFVariable(variableName: variableToDelete)
            print("Deleted NVRAM Variable \(variableToDelete)")
        } catch {
            print(error.localizedDescription)
        }
    default:
        break
    }
}
