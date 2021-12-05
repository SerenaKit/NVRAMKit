# libNVRAMSwift

A Library to manage NVRAM Stuff, written in Swift.
CLI Example utility has only been tested on jailbroken iOS

## Library Usage
Declare a new instance of the NVRAM Struct, for example:
```swift
let nvram = NVRAM()
```

### Getting value of existing NVRAM Variable
use the `OFVariableValue` to get the value of an existing NVRAM Variable. Example:
```swift
let nvram = NVRAM()
let nvramVariableName = "SystemAudioVolume"
do {
  // Returns the value of NVRAM variable "SystemAudioVolume"
  let value = try nvram.OFVariableValue(variableName: nvramVariableName)
} catch {
  print(error.localizedDescription)
}
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
