//
//  MIDIDevice.swift
//  Proteusific
//
//  Created by Adam Jansch on 06/12/2020.
//

import Foundation
import CoreMIDI

struct MIDIDevice {
	// MARK: - ENUMS
	// MARK: Data enums
	enum Property {
		case displayName
		case manufacturer
		case model
		case name
		case offline
		
		var id: CFString {
			switch self {
			case .displayName:
				return kMIDIPropertyDisplayName
			case .manufacturer:
				return kMIDIPropertyManufacturer
			case .model:
				return kMIDIPropertyModel
			case .name:
				return kMIDIPropertyName
			case .offline:
				return kMIDIPropertyOffline
			}
		}
	}
	
	
	// MARK: - PROPERTIES
	// MARK: Stored properties
	let objectRef: MIDIObjectRef
	
	// MARK: Computed properties
	var displayName: String? {
		return string(for: .displayName)
	}
	
	var manufacturer: String? {
		return string(for: .manufacturer)
	}
	
	var model: String? {
		return string(for: .model)
	}
	
	var name: String? {
		return string(for: .name)
	}
	
	var offline: Bool {
		guard let offline = int(for: .offline) else {
			return true
		}
		
		return offline > 0
	}
	
	
	// MARK: - METHODS
	// MARK: Poperty methods
	func int(for property: Property) -> Int32? {
		var intValue: Int32 = 0
		let status = MIDIObjectGetIntegerProperty(objectRef, property.id, &intValue)
		
		guard status == noErr else {
			let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
			print("Error getting int property from deviceRef \(objectRef): \(error)")
			return nil
		}
		
		return intValue
	}
	
	func string(for property: Property) -> String? {
		var stringValue: Unmanaged<CFString>?
		let status = MIDIObjectGetStringProperty(objectRef, property.id, &stringValue)
		
		guard status == noErr else {
			let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
			print("Error getting string property from deviceRef \(objectRef): \(error)")
			return nil
		}
		
		guard let string = stringValue else {
			return nil
		}
		
		return string.takeRetainedValue() as String
	}
}
