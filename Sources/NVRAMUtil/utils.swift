// Includes subcommands used by the program
import ArgumentParser
import NVRAMKit
import Foundation

let instance = NVRAM()

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
struct setValue: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "set", abstract: "Sets the value of a specified NVRAM variable"
    )
    
    @Argument(help: "The NVRAM Variable to set the value of")
    var variable: String
    
    @Argument(help: "The Value to set for the specified NVRAM Variable")
    var value: String
    
    func run() throws {
        try instance.SetValue(forVariable: variable, toValue: value)
        print("Set value of variable \(variable) to \(value)")
    }
}

/// The subcommand for deleting NVRAM Variable(s)
struct deleteNVRAMVariable: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "delete", abstract: "Deletes specified NVRAM Variable(s), or all"
    )

    @Argument(help: "The NVRAM Variable[s] to delete")
    var variables: [String] = []
    
    @Flag(help: "Delete all NVRAM Variables")
    var all: Bool = false
    
    func run() throws {
        for variable in variables {
            try instance.deleteVariable(variable)
        }
        
        if all {
            guard let dict = try instance.GetAllVariables() else {
                throw CleanExit.message("Unable to get all NVRAM Variables in order to delete them")
            }
            
            for key in dict.keys {
                try instance.deleteVariable(key)
            }
        }
    }
}

/// The subcommand for syncing NVRAM Variable(s)
struct syncNVRAMVariable: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "sync", abstract: "Syncs specified NVRAM Variable(s), or all"
    )
    
    @Argument(help: "The NVRAM Variable(s) to sync")
    var variables: [String] = []
    
    @Flag(help: "Sync all the variables")
    var all: Bool = false
    
    @Flag(help: "Force Sync the NVRAM Variables (not recommended!)")
    var forceSync: Bool = false
    
    func run() throws {
        for variable in variables {
            try instance.syncVariable(variable, forceSync: forceSync)
        }
    
        if all {
            guard let dict = try instance.GetAllVariables() else {
                throw CleanExit.message("Unable to get all NVRAM Variables to sync")
            }
            
            for key in dict.keys {
                try instance.syncVariable(key, forceSync: forceSync)
            }
        }
    }
}
