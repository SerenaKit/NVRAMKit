// Includes subcommands used by the program
import ArgumentParser
import NVRAMKit
import Foundation

/// The subcommand for getting the value(s) of NVRAM Variables
struct getValue: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "get", abstract: "Gets the value of specified NVRAM Variable(s), or all NVRAM Variables"
    )
    
    @Argument(help: "The variable(s) to print the value of")
    var variables: [String] = []
    
    @Flag(help: "Print all NVRAM Variables and their values")
    var printAll: Bool = false
    
    @Flag(help: "List all NVRAM Variables, but without their values")
    var listAll: Bool = false
    
    func run() throws {
        let instance = NVRAM()
        for variable in variables {
            let value = try instance.GetVariable(name: variable)
            print("\(variable): \(value ?? "Value not available")")
        }
        
        if printAll || listAll {
            guard let dict = try instance.GetAllVariables() else {
                throw CleanExit.message("Unable to get list of NVRAM Variables and their values")
            }
            
            // If printAll is true, print all the variables and their values
            if printAll {
                for (key, value) in dict {
                    print("\(key): \(value ?? "Value not available")")
                }
            }
            
            // if listAll is true, print only the variable names
            if listAll {
                print(dict.keys.joined(separator: "\n"))
            }
        }
    }
}

/// The subcommand to set the value of an NVRAM Variable
struct setNVRAMValue: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "set", abstract: "Sets the value of a specified NVRAM variable"
    )
    
    @Argument(help: "The NVRAM Variable to set the value of")
    var variable: String
    
    @Argument(help: "The Value to set for the specified NVRAM Variable")
    var value: String
    
    func run() throws {
        let instance = NVRAM()
        try instance.SetValue(forVariable: variable, toValue: value)
        print("Set value of variable \(variable) to \(value)")
    }
}

/// The subcommand for deleting an NVRAM Variable
struct deleteNVRAMVariable: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "delete", abstract: "Deletes a specified NVRAM Variable"
    )

    @Argument(help: "The NVRAM Variable to delete")
    var variable: String
    
    func run() throws {
        let instance = NVRAM()
        try instance.deleteVariable(variable)
        print("Deleted variable \(variable)")
    }
}
