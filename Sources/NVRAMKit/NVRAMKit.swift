import IOKit
import Foundation

/// Converts a Mach Error String description to a Swift String
internal func MachErrorToSwiftString(_ errorValue: kern_return_t) -> String? {
    // Get the error as a CString first
    guard let errCString = mach_error_string(errorValue) else {
        return nil
    }
    // Then convert it to a Swift String
    return String(cString: errCString)
}

/// Manages stuff to do with NVRAM Variables 
public class NVRAM {
    
    enum NVRAMErrors: Error, LocalizedError, CustomStringConvertible {
        case triedToAccessVariableThatDoesntExist(variableName: String)
        case operationReturnedNonKernSuccess(operationDescription: String, kernReturnCode: kern_return_t)
        
        public var description: String {
            switch self {
            case .triedToAccessVariableThatDoesntExist(let variableName):
                return "Tried to access variable \"\(variableName)\" but said variable doesn't exist!"
            case .operationReturnedNonKernSuccess(let operationDescription, let kernReturnCode):
                return "Operation \(operationDescription) Encountered following Error: \(MachErrorToSwiftString(kernReturnCode) ?? "Unknown Error")"
            }
        }
        
        public var errorDescription: String? {
            return description
        }
    }
    
    /// The IORegistryEntry of NVRAM Variables
    var RegistryEntry: io_registry_entry_t
    
    /// Initializes a new NVRAM instance with the specified `io_registry_entry`
    public init(RegistryEntry: io_registry_entry_t) {
        self.RegistryEntry = RegistryEntry
    }
    
    /// Initializes a new NVRAM instance with the defualt RegistryEntry for NVRAM Variables
    public init(RegistryEntryPath path: String = "IODeviceTree:/options") {
        var MasterPort: mach_port_t
        
        // macOS 12.0+ prefer kIOMainPortDefault to kIOMasterPortDefault
        // However kIOMainPortDefault is only available on macOS 12 and above
        if #available(macOS 12, *) {
            MasterPort = kIOMainPortDefault
        } else {
            MasterPort = kIOMasterPortDefault
        }
        
        self.RegistryEntry = IORegistryEntryFromPath(MasterPort, path)
    }
    
    /// Returns a Boolean based on whether or not an NVRAM Variable exists.
    /// Note that this function may not be accurate if the variables exist in a different RegistryEntry than the one being used
    public func NVRAMVariableExists(variableName name: String) -> Bool {
        IORegistryEntryCreateCFProperty(RegistryEntry, name as CFString, kCFAllocatorDefault, 0) != nil
    }
    
    /// Returns the value of an NVRAM Variable as an optional String
    public func GetVariable(name: String) throws -> String? {
        guard NVRAMVariableExists(variableName: name) else {
            throw NVRAMErrors.triedToAccessVariableThatDoesntExist(variableName: name)
        }
        
        // the raw value of the variable
        let rawValue = IORegistryEntryCreateCFProperty(RegistryEntry, name as CFString, kCFAllocatorDefault, 0)
            .takeRetainedValue()
        // If rawValue is data -- convert it
        if let rawValueData = rawValue as? Data {
            return String(data: rawValueData, encoding: .utf8)
        }
        
        return rawValue as? String
    }
    
    /// Sets the value of a specified NVRAM Variable to a specified value
    public func SetValue(forVariable variable: String, toValue value: String) throws {
        let status = IORegistryEntrySetCFProperty(RegistryEntry, variable as CFString, value as CFString)
        
        guard status == KERN_SUCCESS else {
            throw NVRAMErrors.operationReturnedNonKernSuccess(
                operationDescription: "Setting NVRAM Variable \(variable) value to \(value) (IORegistryEntrySetCFProperty)",
                kernReturnCode: status
            )
        }
    }
    
    /// Deletes a specified variable
    public func deleteVariable(_ variable: String) throws {
        try SetValue(forVariable: kIONVRAMDeletePropertyKey, toValue: variable)
    }
    
    /// Syncs a specified NVRAM Variable,
    /// if `forceSync` is set to true, then the FORCESYNCNOW Key is used,
    /// Otherwise the normal SyncNow key is used
    public func syncVariable(_ variable: String, forceSync: Bool = false) throws {
        // If forceSync is true, declare SyncKey as the force sync key,
        // Otherwise declare it as the normal sync key
        let SyncKey = forceSync ? "IONVRAM-FORCESYNCNOW-PROPERTY" : kIONVRAMSyncNowPropertyKey
        try SetValue(forVariable: SyncKey, toValue: variable)
    }
    
    /// Returns an optional dictionary of all variables and their values
    public func GetAllVariables() throws -> [String: String?]? {
        let dict = UnsafeMutablePointer<Unmanaged<CFMutableDictionary>?>.allocate(capacity: 1)
        defer {
            // Make sure to deallocate the dictionary once we're done with it
            dict.deallocate()
        }
        
        let status = IORegistryEntryCreateCFProperties(
            RegistryEntry, dict, kCFAllocatorDefault, 0
        )
        guard status == KERN_SUCCESS else {
            throw NVRAMErrors.operationReturnedNonKernSuccess(operationDescription: "Accessing All NVRAM Variables (IORegistryEntryCreateCFProperties)", kernReturnCode: status)
        }
        
        let rawDict = dict.pointee?.takeRetainedValue() as? [String: Any?]
        // for each value in the dict, if the value is Data
        // then try convert it
        let dictMapped = rawDict?.mapValues { (value) -> String? in
            if let valueData = value as? Data {
                return String(data: valueData, encoding: .utf8)
            }
            
            return value as? String
        }
        
        return dictMapped
    }
    
    // We need to free the RegistryEntry once we're done with it
    deinit {
        IOObjectRelease(RegistryEntry)
    }
}
