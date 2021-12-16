# NVRAMKit

A Library and CLI Utility to manage NVRAM Stuff, written in Swift.

# Library
## Adding Library to project
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
use the `OFVariableValue` function to get the value of an existing NVRAM Variable. Example:
```swift
let nvram = NVRAM()
let nvramVariableName = "SystemAudioVolume"
// Returns the value of NVRAM variable "SystemAudioVolume"
let value = nvram.OFVariableValue(variableName: nvramVariableName)
print(value ?? "Unknown Value")
```

### Creating / Setting variables of NVRAM Variables
for creating a new NVRAM variable or setting the value of an existing NVRAM Variable, use the `createOrSetOFVariable` function. Note that this function throws. Example:
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
use the `deleteOFVariable` function to delete an NVRAM Variable. Example:
```swift
let nvram = NVRAM()
do {
  // Deletes NVRAM Variable by the name of "randomVariable"
  try nvram.deleteOFVariable(variableName: "randomVariable")
} catch {
  print(error.localizedDescription)
}
```

### Checking for existance of NVRAM Variable
use the `OFVariableExists` function to return true or false based on whether or not an NVRAM Variable exists. Example:
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
