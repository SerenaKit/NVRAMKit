// NVRAMUtilCLI
// A CLI Utility to demonstrate libNRVAMSwift

import Foundation
#if canImport(libNVRAMSwift)
import libNVRAMSwift
#endif

// Print the help message if the user used --help/-h or if no arguments were specified
if CMDLineArgs.contains("--help") || CMDLineArgs.contains("-h") || CMDLineArgs.isEmpty {
    print(helpMessage)
    exit(0)
}
let nvram = NVRAM()


/// Array of variables that the utility should set values for, ie test=testValue
let variablesToSet = CMDLineArgs.filter() { $0.contains("=") }

for variable in variablesToSet {
    // Divide the variable name given, and the variable value given
    let components = variable.components(separatedBy: "=")
    let variableName = components[0]
    let variableValue = components[1]
    do {
        try nvram.createOrSetOFVariable(variableName: variableName, variableValue: variableValue)
    } catch {
        print(error.localizedDescription)
    }
}

if CMDLineArgs.contains("--delete") || CMDLineArgs.contains("-d") {
    let variableToDelete = parseCMDLineArgument(longOpt: "--delete", shortOpt: "-d", description: "NVRAM Variable to delete")
    if !nvram.OFVariableExists(variableName: variableToDelete) {
        print("NVRAM Variable \(variableToDelete) doesn't exist..still proceeding to (try) deleting.")
    }
    do {
        try nvram.deleteOFVariable(variableName: variableToDelete)
        print("Deleted NVRAM variable \(variableToDelete)")
    } catch {
        print(error.localizedDescription)
    }
}

if CMDLineArgs.contains("--all") || CMDLineArgs.contains("-a") {
    if let dict = nvram.getAllOFVariables(convertOFVariablesValue: !shouldPrintRawValues) {
        for (key, value) in dict {
            print("\(key): \(value ?? "Unknown Value")")
        }
    }
}

if CMDLineArgs.contains("--print") || CMDLineArgs.contains("-p") {
    let variableToPrint = parseCMDLineArgument(longOpt: "--print", shortOpt: "-p", description: "NVRAM Variable to print")
    do {
        let value = try nvram.OFVariableValue(variableName: variableToPrint, convertOFVariableValue: !shouldPrintRawValues)
        print("\(variableToPrint): \(value)")
    } catch {
        print(error.localizedDescription)
    }
}
