import ArgumentParser
import NVRAMKit
import IOKit

struct NVRAMUtil: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "nvramutil", abstract: "CLI Tool to manage the NVRAM on macOS", subcommands: [
            getValue.self,
            setNVRAMValue.self,
            deleteNVRAMVariable.self
        ]
    )
}

NVRAMUtil.main()

