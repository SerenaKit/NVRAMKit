import ArgumentParser

struct NVRAMUtil: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "nvramutil", abstract: "CLI Tool to manage the NVRAM on macOS", subcommands: [
            getValue.self,
            setValue.self,
            deleteNVRAMVariable.self,
            syncNVRAMVariable.self
        ]
    )
}

NVRAMUtil.main()

