let CMDLineArgs = Array(CommandLine.arguments.dropFirst())

func parseCMDLineArgument(longOpt:String, shortOpt:String? = nil, fromArgArr ArgArr:[String] = CMDLineArgs, description:String) -> String {
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

let shouldPrintRawValues = CMDLineArgs.contains("--raw") || CMDLineArgs.contains("-r")

let helpMessage = """
NVRAMUtil - By Serena-io
A CommandLine tool to demonstrate libNVRAMSwift
Usage: nvramutil <option> [NVRAM Variable..]

Options:
    -a, --all                                       Print all NVRAM Variables
    -p, --print  VARIABLE-TO-PRINT                  Print a specicifed NVRAM Variable
    -d, --delete VARIABLE-TO-DELETE                 Specify a NVRAM Variable to delete
    -r, --raw                                       Print the raw value(s) of NVRAM Variables instead of the converted value

For setting an NVRAM Variable to a specific value:
VARIABLE-NAME=VARIABLE-VALUE. Example: nvramutil example=value1
"""
