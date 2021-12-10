import Foundation
struct CMDLineSupport {
    
    static let CMDLineArgs = Array(CommandLine.arguments.dropFirst())
    
    static func parseCMDLineArgument(longOpt:String, shortOpt:String? = nil, fromArgArr ArgArr:[String] = CMDLineArgs, description:String) -> String {
        var optToParse:String {
            if let shortOpt = shortOpt {
                return ArgArr.contains(longOpt) ? longOpt : shortOpt
            } else {
                return longOpt
            }
        }
        guard let index = ArgArr.firstIndex(of: optToParse), CMDLineArgs.indices.contains(index + 1) else {
            fatalError("User used \(optToParse) however did not specify a \(description).")
        }
        return CMDLineArgs[index + 1]
    }
    
    static let shouldPrintHelpMessage = CMDLineArgs.contains("--help") || CMDLineArgs.contains("-h")
    static let useJSON = CMDLineArgs.contains("--json") || CMDLineArgs.contains("-j")
    
    static let helpMessage = """
NVRAMUtil - By NSSerena
A CommandLine tool to demonstrate libNVRAMSwift
Usage: nvramutil <option> [NVRAM Variable..]

Options:
    -a, --all                                       Print all NVRAM Variables and their values
    -l --list                                       List all NVRAM Variables without their values
    -j, --json                                      Output any NVRAM Variable values in JSON format
    -p, --print  VARIABLE-TO-PRINT                  Print a specicifed NVRAM Variable
    -d, --delete VARIABLE-TO-DELETE                 Specify a NVRAM Variable to delete

For setting an NVRAM Variable to a specific value:
VARIABLE-NAME=VARIABLE-VALUE.
Examples:
    nvramutil randomVar=randomValue
    nvramutil -d randomVar
    nvramutil -a -j
"""
    
    public init() {}
}

internal func convertToJSON(Dict: [String : String]) -> Any {
    guard let data = try? JSONSerialization.data(withJSONObject: Dict, options: .prettyPrinted), let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
        fatalError("Unable to convert \"\(Dict)\" to JSON. Sorry.")
    }
    return json
}

/// Prints in JSON Format if the user used --json/-j, otherwise print normally
internal func printVar(dict: [String : String]) {
    if CMDLineSupport.useJSON {
        let json = convertToJSON(Dict: dict)
        print(json)
    } else {
        for (key, value) in dict {
            print("\(key): \(value)")
        }
    }
}
