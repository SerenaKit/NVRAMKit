import Foundation
struct CMDLineSupport {
    
    // all command line args inputted by the user
    static let CMDLineArgs = Array(CommandLine.arguments.dropFirst())
    
    // command line args inputted by the user that start with a dash
    // ie --print or -d
    static let DashCMDLineArgs = CMDLineArgs.filter {
        $0.starts(with: "-")
    }
    
    static func parseCMDLineArgument(longOpt:String, shortOpt:String? = nil, fromArgArr ArgArr:[String] = CMDLineArgs, description:String) -> String {
        var optToParse:String {
            if let shortOpt = shortOpt {
                return ArgArr.contains(longOpt) ? longOpt : shortOpt
            } else {
                return longOpt
            }
        }
        guard let index = ArgArr.firstIndex(of: optToParse), CMDLineArgs.indices.contains(index + 1) else {
            print("User used \(optToParse) however did not specify a \(description).")
            exit(EXIT_FAILURE)
        }
        return CMDLineArgs[index + 1]
    }
    
    static let shouldPrintHelpMessage = CMDLineArgs.contains("--help") || CMDLineArgs.contains("-h")
    static let useJSON = CMDLineArgs.contains("--json") || CMDLineArgs.contains("-j")
    static let useXML = CMDLineArgs.contains("--xml") || CMDLineArgs.contains("-x")
    
    static let helpMessage = """
NVRAMUtil - By Serena-io
A CommandLine tool to manage NVRAM Stuff, made as a demonstration for the NVRAMKit library
Usage: nvramutil <option> [NVRAM Variable..]

Options for listing:
    -a, --all                                       Print all NVRAM Variables and their values
    -l --list                                       List all NVRAM Variables without their values

Options for formatting:
    -j, --json                                      Output any NVRAM Variable values in JSON format
    -x, --xml                                       Output any NVRAM Variable values in XML Format

Options for managing NVRAM Variables:
    -p, --print  VARIABLE-TO-PRINT                  Print a specicifed NVRAM Variable
    -d, --delete VARIABLE-TO-DELETE                 Specify a NVRAM Variable to delete
    VARIABLE-NAME=VALUE                             Creates or sets the value of an existing NVRAM to one thats specified, ie randomVar=randomValue.

Examples:
    nvramutil randomVar=randomValue
    nvramutil -d randomVar
    nvramutil -a -j
"""
    
    public init() {}
}

internal func convertToJSON(fromDict Dict: [String : String]) -> Any {
    guard let data = try? JSONSerialization.data(withJSONObject: Dict, options: .prettyPrinted), let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
        fatalError("Unable to convert \"\(Dict)\" to JSON. Sorry.")
    }
    return json
}

internal func convertToXML(fromDict Dict: [String : String]) -> String {
    let encoder = PropertyListEncoder()
    encoder.outputFormat = .xml
    
    guard let encoded = try? encoder.encode(Dict), let strRaw = String(data: encoded, encoding: .utf8) else {
        fatalError("Unable to get XML from dictionary, Sorry.")
    }
    
    return String(format: "%@", strRaw)
}

/// Prints in JSON Format if the user used --json/-j, otherwise print normally
internal func printFormatted(FromDict dict: [String : String]) {
    if CMDLineSupport.useJSON {
        let json = convertToJSON(fromDict: dict)
        print(json)
    } else if CMDLineSupport.useXML {
        let xml = convertToXML(fromDict: dict)
        print(xml)
    } else {
        for (key, value) in dict {
            print("\(key): \(value)")
        }
    }
}
