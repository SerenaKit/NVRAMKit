// When the project is compiled for iOS devices, importing IOKit manually won't be needed
#if canImport(IOKit)
import IOKit
#endif
import Foundation

public class NVRAM {
    /// Returns the IOEntryRegistry for NVRAM Variables
    private let NVRAMIORegistryEntry: io_registry_entry_t = {
        return IORegistryEntryFromPath(kIOMasterPortDefault, "IODeviceTree:/options")
    }()
    
    /// Returns true or false based on whether or not the specified OF Variable exists
    public func OFVariableExists(variableName name:String) -> Bool {
        return IORegistryEntryCreateCFProperty(NVRAMIORegistryEntry, name as CFString, kCFAllocatorDefault, 0) != nil
    }
    
    /// Returns the string description of a mach error
    internal func machErrorString(errorValue: mach_error_t) -> String {
        guard let err = mach_error_string(errorValue) else {
            return "Unknown Error, error value: \(errorValue)"
        }
        return String(cString: err)
    }
    
    /// Converts the value of an OF Variable
    internal func tryConvertToString(_ value: Any) -> String? {
        // Convert it if it's Data
        if let valueData = value as? Data {
            return String(data: valueData, encoding: .utf8)
        } else if let valStr = value as? String {
            return valStr
        }
        return "\(value)"
    }
    
    /// Returns the value of an NVRAM Variable
    public func OFVariableValue(variableName name: String) -> String? {
        
        guard OFVariableExists(variableName: name) else {
            return nil
        }
        
        let ref = IORegistryEntryCreateCFProperty(NVRAMIORegistryEntry, name as CFString, kCFAllocatorDefault, 0).takeRetainedValue()
        
        let converted = tryConvertToString(ref)
        return converted
    }
    
    /// Create or set a specified NVRAM Variable to a specified value
    public func createOrSetOFVariable(variableName name: String, variableValue value: String) throws {
        
        let setStatus = IORegistryEntrySetCFProperty(NVRAMIORegistryEntry, name as CFString, value as CFTypeRef)
        guard setStatus == KERN_SUCCESS else {
            let errorEncountered = machErrorString(errorValue: setStatus)
            throw libNVRAMErrors.couldntSetOFVariableValue(variableName: name, variableValueGiven: value, errorEncountered: errorEncountered)
        }
    }
    
    
    /// Delete a specified NVRAM Variable
    public func deleteOFVariable(variableName name: String) throws {
        try createOrSetOFVariable(variableName: kIONVRAMDeletePropertyKey, variableValue: name)
    }
    
    public func syncOFVariable(variableName name: String, forceSync: Bool) throws {
        // If forceSync is true, use the force-sync-now key, otherwise use the normal one
        let syncKey = forceSync ? "IONVRAM-FORCESYNCNOW-PROPERTY" : kIONVRAMSyncNowPropertyKey
        try createOrSetOFVariable(variableName: syncKey, variableValue: name)
    }
    /// Returns a dictionary of all OF Variable names and values
    public func getAllOFVariables() -> [String : String?]? {
        let dict = UnsafeMutablePointer<Unmanaged<CFMutableDictionary>?>.allocate(capacity: 1)
        defer {
            dict.deallocate()
        }
        
        let status = IORegistryEntryCreateCFProperties(NVRAMIORegistryEntry, dict, kCFAllocatorDefault, 0)
        
        // Make sure we got the dictionary successfully
        guard status == KERN_SUCCESS else {
            return nil
        }
        
        // Dictionary of unconverted OF Variable values
        let rawDict = dict.pointee?.takeRetainedValue() as? Dictionary<String, Any>
        
        // Dictionary of converted OF Variable values
        let convertedDict = rawDict?.mapValues() { return tryConvertToString($0) }
        
        return convertedDict
    }
    
    public init() {}
    
    // Make sure we free the NVRAM IORegistryEntry
    deinit {
        IOObjectRelease(NVRAMIORegistryEntry)
    }
}

/// Errors that could be encountered with NVRAM Functions
enum libNVRAMErrors:Error  {
    case couldntSetOFVariableValue(variableName:String, variableValueGiven:Any, errorEncountered:String)
}

extension libNVRAMErrors:LocalizedError {
    var description: String {
        switch self {
        case .couldntSetOFVariableValue(let variableName, let variableValueGiven, let errorEncountered):
            return "Couldn't Set Value of NVRAM Variable \"\(variableName)\" to value \(variableValueGiven), error: \(errorEncountered)"
        }
    }
}
