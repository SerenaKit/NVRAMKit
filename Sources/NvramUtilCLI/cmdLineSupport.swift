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

let shouldForceSync = CMDLineArgs.contains("--force-sync") || CMDLineArgs.contains("-f")

let helpMessage = """
NVRAMUtil - By NSSerena
A CommandLine tool to demonstrate libNVRAMSwift
Usage: nvramutil <option> [NVRAM Variable..]

Options:
    -a, --all                                       Print all NVRAM Variables and their values
    -l --list                                       List all NVRAM Variables without their values
    -f, --force-sync                                Force Sync NVRAM Variables that are set by NVRAMUtil
    -p, --print  VARIABLE-TO-PRINT                  Print a specicifed NVRAM Variable
    -d, --delete VARIABLE-TO-DELETE                 Specify a NVRAM Variable to delete
    -s, --sync   VARIABLE-TO-SYNC                   Sync a specified Variable

For setting an NVRAM Variable to a specific value:
VARIABLE-NAME=VARIABLE-VALUE. Example: `nvramutil example=value1`
"""
