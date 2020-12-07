//
//  MIDIDevice.swift
//  Proteusific
//
//  Created by Adam Jansch on 06/12/2020.
//

import Foundation
import CoreMIDI

struct MIDIDevice: MIDIObject {
	// MARK: - PROPERTIES
	// MARK: MIDIObject properties
	let objectRef: MIDIObjectRef
	
	// MARK: Computed properties
	var manufacturer: String? {
		return MIDIProperty.manufacturer.value(from: objectRef) as? String
	}
	
	var model: String? {
		return MIDIProperty.model.value(from: objectRef) as? String
	}
}
