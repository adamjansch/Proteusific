//
//  MIDIObject.swift
//  Proteusific
//
//  Created by Adam Jansch on 07/12/2020.
//

import Foundation
import CoreMIDI

enum MIDIProperty {
	case displayName
	case manufacturer
	case model
	case name
	case offline
	case uniqueID
	
	private var id: CFString {
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
		case .uniqueID:
			return kMIDIPropertyUniqueID
		}
	}
	
	func value(from midiObjectRef: MIDIObjectRef) -> Any? {
		switch self {
		case .displayName,
			 .manufacturer,
			 .model,
			 .name:
			var stringValue: Unmanaged<CFString>?
			let status = MIDIObjectGetStringProperty(midiObjectRef, id, &stringValue)
			
			guard status == noErr else {
				let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
				print("Error getting string property from objectRef \(midiObjectRef): \(error)")
				return nil
			}
			
			guard let string = stringValue else {
				return nil
			}
			
			return string.takeRetainedValue() as String
			
		case .offline,
			 .uniqueID:
			var intValue: Int32 = 0
			let status = MIDIObjectGetIntegerProperty(midiObjectRef, id, &intValue)
			
			guard status == noErr else {
				let error = NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
				print("Error getting int property from objectRef \(midiObjectRef): \(error)")
				return nil
			}
			
			return intValue
		}
	}
}

protocol MIDIObject {
	var objectRef: MIDIObjectRef { get }
	var displayName: String? { get }
	var name: String? { get }
	var online: Bool { get }
}

extension MIDIObject {
	var displayName: String? {
		return MIDIProperty.displayName.value(from: objectRef) as? String
	}
	
	var name: String? {
		return MIDIProperty.name.value(from: objectRef) as? String
	}
	
	var online: Bool {
		guard let offline = MIDIProperty.offline.value(from: objectRef) as? Int else {
			return true
		}
		
		return offline == 0
	}
	
	var uniqueID: Int? {
		return MIDIProperty.uniqueID.value(from: objectRef) as? Int
	}
}
