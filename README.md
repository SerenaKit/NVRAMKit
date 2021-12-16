# NVRAMKit

A Library and CLI Utility to manage NVRAM Stuff, written in Swift.

# Library
## Adding Library to Project
Simply add this line to the `dependencies` section of your `Package.swift` file:
```swift
.package(url: "https://github.com/Serena-io/NVRAMKit.git", branch: "main")
```

## Library Usage
Declare a new instance of the NVRAM Struct, for example:
```swift
let nvram = NVRAM()
```

### Getting value of existing NVRAM Variable
Use NVRAM Class Subscript with the `variableName` Parameter, Example:
```swift
let nvram = NVRAM()
// Returns the value of NVRAM variable "SystemAudioVolume"
let value = nvram["SystemAudioVolume"]
print(value ?? "Unknown Value")
```

### Creating / Setting variables of NVRAM Variables
For creating a new NVRAM variable or setting the value of an existing NVRAM Variable, use the `createOrSetOFVariable` function. Note that this function throws. Example:
```swift
let nvram = NVRAM()
// Creates a new NVRAM Variable by the name of "exampleVariable" with value "example value"
let variableName = "exampleVariable"
let variableValue = "example value"
do {
  try nvram.createOrSetOFVariable(variableName: variableName, variableValue: variableValue)
} catch {
  print(error.localizedDescription)
}
```

### Deleting an NVRAM Variable
Use the `deleteOFVariable` function to delete an NVRAM Variable. Example:
```swift
let nvram = NVRAM()
do {
  // Deletes NVRAM Variable by the name of "randomVariable"
  try nvram.deleteOFVariable(variableName: "randomVariable")
} catch {
  print(error.localizedDescription)
}
```

### Syncing an NVRAM Variable
Use the `syncOFVariable` function to sync an NVRAM Variable. In the Parameters, you can specify force syncing the variable (though not recommended at all), Example:
```swift
let nvram = NVRAM()
do {
  // Syncs the NVRAM Variable "SystemAudioVolume"
  try nvram.syncOFVariable(variableName: SystemAudioVolume, forceSync: false)
} catch {
  print(error.localizedDescription)
}
```
### Checking for existance of NVRAM Variable
Use the `OFVariableExists` function to return true or false based on whether or not an NVRAM Variable exists. Example:
```swift
let nvram = NVRAM()
// Returns true or false based on whether or not an NVRAM Variable by the name of "SystemAudioVolume" exists
let variableExists = nvram.OFVariableExists(variableName: "SystemAudioVolume")
print(variableExists)
```

### Getting all NVRAM Variables and their values
Use `getAllOFVariables`, which returns a Dictionary of Variable names and values. Example:
```swift
let nvram = NVRAM() 
let allVariables = nvram.getAllOFVariables()
for (key, value) in allVariables {
  print("\(key): \(value ?? "Unknown Value")")
}
```

# CLI Utility
The CLI Utility, going by the name `NVRAMUtil`, uses the NVRAMKit library to manage NVRAM Variables. 

NVRAMUtil runs on both Jailbroken iOS and macOS Devices
## Options
### Formatting Options:
- `-j, --json` Outputs specified NVRAM Variable(s) and their values in JSON Format, example:
- `-x, --xml` Outputs specified NVRAM Variable(s) and their values in XML Format, example:

### Listing Options:
- `-a, --all` Prints all NVRAM Variables and their values
- `-l, --list` Prints all NVRAM Variable names without their values

### Managing individual NVRAM Variables:
- `-p, --print VARIABLE-TO-PRINT` Prints a specified NVRAM Variable
- `-d, --delete VARIABLE-TO-DELETE` Delete a specified NVRAM Variable
- `VARIABLE-NAME=VARIABLE-VALUE` Set / Create a NVRAM Variable with a specified value

