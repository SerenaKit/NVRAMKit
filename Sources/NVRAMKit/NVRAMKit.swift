// When the project is compiled for iOS devices, importing IOKit manually won't be needed
#if canImport(IOKit)
import IOKit
#endif
import Foundation


/// A Class which manages NVRAM Stuff
/// such as getting the values of, deleting, and syncing NVRAM Variables
public class NVRAM {
    
    /// Returns the IOEntryRegistry for NVRAM Variables
    let NVRAMIORegistryEntry: io_registry_entry_t = {
        return IORegistryEntryFromPath(kIOMasterPortDefault, "IODeviceTree:/options")
    }()
    
    /// Returns true or false based on whether or not the specified NVRAM Variable exists
    public func OFVariableExists(named name:String) -> Bool {
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
    
    /// A Subscript which returns the value of a specified NVRAM Variable
    public subscript(_ name: String) -> String? {
        get {
            // Make sure the variable exists first
            // otherwise return nil
            guard OFVariableExists(named: name) else {
                return nil
            }
            
            let ref = IORegistryEntryCreateCFProperty(NVRAMIORegistryEntry, name as CFString, kCFAllocatorDefault, 0).takeRetainedValue()
            
            let converted = tryConvertToString(ref)
            return converted
        }
    }
    /// Create or set a specified NVRAM Variable to a specified value
    public func setOFVariable(named name: String, toValue value: Any) throws {
        
        let setStatus = IORegistryEntrySetCFProperty(NVRAMIORegistryEntry, name as CFString, value as CFTypeRef)
        guard setStatus == KERN_SUCCESS else {
            let errorEncountered = machErrorString(errorValue: setStatus)
            throw NVRAMErrors.couldntSetOFVariableValue(variableName: name, variableValueGiven: value, errorEncountered: errorEncountered)
        }
    }
    
    
    /// Delete a specified NVRAM Variable
    public func deleteOFVariable(named name: String) throws {
        try setOFVariable(named: kIONVRAMDeletePropertyKey, toValue: name)
        
        // Make sure the variable doesn't exist
        // After we tried to delete it
        guard !OFVariableExists(named: name) else {
            throw NVRAMErrors.OFVariableStillExistsAfterAttemptedDeletion(variableName: name)
        }
    }
    
    /// Syncs a specified NVRAM Variable
    public func syncOFVariable(named name: String, forceSync: Bool) throws {
        // If forceSync is true, use the force-sync-now key, otherwise use the normal one
        let syncKey = forceSync ? "IONVRAM-FORCESYNCNOW-PROPERTY" : kIONVRAMSyncNowPropertyKey
        // to sync an NVRAM Variable, we set the sync key value to the value of the nvram variable
        try setOFVariable(named: syncKey, toValue: name)
    }
    
    /// Returns a dictionary of all OF Variable names and values
    public func getAllOFVariables() -> [String : String?]? {
        let dict = UnsafeMutablePointer<Unmanaged<CFMutableDictionary>?>.allocate(capacity: 1)
        defer {
            // Make sure to deallocate the dictionary once we're done with it
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
    
    /// Initializes a new NVRAM Instance
    public init() {}
    
    // Make sure we free the NVRAM IORegistryEntry
    deinit {
        IOObjectRelease(NVRAMIORegistryEntry)
    }
    
}

public enum NVRAMErrors: LocalizedError {
    case couldntSetOFVariableValue(variableName: String, variableValueGiven: Any, errorEncountered: String)
    case OFVariableStillExistsAfterAttemptedDeletion(variableName: String)
}

extension NVRAMErrors {
    public var errorDescription: String? {
        switch self {
        case .couldntSetOFVariableValue(let variableName, let variableValueGiven, let errorEncountered):
            return "Couldn't set value of NVRAM Variable \(variableName) to \(variableValueGiven): \(errorEncountered)"
        case .OFVariableStillExistsAfterAttemptedDeletion(let variableName):
            return "Tried to delete NVRAM Variable \(variableName), but variable STILL Exists."
        }
    }
    
    /// Provide  Recovery Suggestions
    public var recoverySuggestion: String? {
        switch self {
        case .couldntSetOFVariableValue(_, _, _), .OFVariableStillExistsAfterAttemptedDeletion(_):
            return "Try running as root."
        }
    }
}
