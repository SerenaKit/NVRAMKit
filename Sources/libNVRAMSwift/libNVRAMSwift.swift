// When the project is compiled for iOS devices, importing IOKit manually won't be needed
#if canImport(IOKit)
import IOKit
#endif
import Foundation

public struct NVRAM {
    
    /// Returns the IOEntryRegistry for NVRAM Variables
    private func getIOEntryReg() -> io_registry_entry_t {
        var masterPort = io_master_t()
        IOMasterPort(bootstrap_port, &masterPort)
        return IORegistryEntryFromPath(masterPort, "IODeviceTree:/options")
    }
    
    /// Returns true or false based on whether or not the specified OF Variable exists
    public func OFVariableExists(variableName name:String) -> Bool {
        let entry = getIOEntryReg()
        defer { IOObjectRelease(entry) }
        return IORegistryEntryCreateCFProperty(entry, name as CFString, kCFAllocatorDefault, 0) != nil
    }
    
    /// Returns the string description of a mach error
    internal func machErrorString(errorValue: mach_error_t) -> String {
        guard let err = mach_error_string(errorValue) else {
            return "Unknown Error, error value: \(errorValue)"
        }
        return String(cString: err)
    }
    
    /// Converts the value of an OF Variable
    internal func convertValueToString(_ value: Any) -> String? {
        // Convert it if it's Data
        if let valueData = value as? Data {
            return String(data: valueData, encoding: .utf8)
        }
        return value as? String
    }
    
    /// Returns the value of an NVRAM Variable
    public func OFVariableValue(variableName name:String) -> String? {
        let entry = getIOEntryReg()
        defer { IOObjectRelease(entry) }
        
        guard OFVariableExists(variableName: name) else {
            return nil
        }
     
        let ref = IORegistryEntryCreateCFProperty(entry, name as CFString, kCFAllocatorDefault, 0).takeRetainedValue()
        
        let converted = convertValueToString(ref)
        return converted
    }
    
    /// Create or set a specified NVRAM Variable to a specified value
    public func createOrSetOFVariable(variableName name:String, variableValue value:Any, syncVariable:Bool = true, forceSyncVariable:Bool = false) throws {
        let entry = getIOEntryReg()
        defer { IOObjectRelease(entry) }
        
        let setStatus = IORegistryEntrySetCFProperty(entry, name as CFString, value as CFTypeRef)
        guard setStatus == KERN_SUCCESS else {
            let errorEncountered = machErrorString(errorValue: setStatus)
            throw libNVRAMErrors.couldntSetOFVariableValue(variableName: name, variableValueGiven: value, errorEncountered: errorEncountered)
        }
        
        // Sync the variable
        if syncVariable {
            // If forceSync is set to true, use the force sync property key rather than the normal one
            let syncPropertyKey = forceSyncVariable ? "IONVRAM-FORCESYNCNOW-PROPERTY" : kIONVRAMSyncNowPropertyKey
            IORegistryEntrySetCFProperty(entry, syncPropertyKey as CFString, name as CFTypeRef)
        }
        
    }
    
    
    /// Delete a specified NVRAM Variable
    public func deleteOFVariable(variableName name:String) throws {
        try createOrSetOFVariable(variableName: kIONVRAMDeletePropertyKey, variableValue: name)
    }
    
    /// Returns a dictionary of all OF Variable names and values
    public func getAllOFVariables() -> [String:String?]? {
        let entry = getIOEntryReg()
        defer { IOObjectRelease(entry) }
        
        let dict = UnsafeMutablePointer<Unmanaged<CFMutableDictionary>?>.allocate(capacity: 1)
        defer { dict.deallocate() }
        
        let status = IORegistryEntryCreateCFProperties(entry, dict, kCFAllocatorDefault, 0)
        
        // Make sure we got the dictionary successfully
        guard status == KERN_SUCCESS else {
            return nil
        }
        
        // Dictionary of unconverted OF Variable values
        let rawDict = dict.pointee?.takeRetainedValue() as? Dictionary<String, Any>
        
        // Dictionary of converted OF Variable values
        let convertedDict = rawDict?.mapValues() { return convertValueToString($0) }
        
        return convertedDict
    }
    
    public init() {}
}

/// Errors that could be encountered with NVRAM Functions
 enum libNVRAMErrors:LocalizedError {
    case couldntSetOFVariableValue(variableName:String, variableValueGiven:Any, errorEncountered:String)
}

/// Error descriptions
extension libNVRAMErrors {
    public var errorDescription: String? {
        switch self {
        case let .couldntSetOFVariableValue(variableName, variableValueGiven, errorEncountered):
            return "Couldn't Set / Create NVRAM Variable of name \(variableName) to value \(variableValueGiven), error encountered: \(errorEncountered)"
        }
    }
}
