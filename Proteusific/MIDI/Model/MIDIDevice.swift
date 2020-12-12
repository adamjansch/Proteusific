//
//  MIDIDevice.swift
//  Proteusific
//
//  Created by Adam Jansch on 06/12/2020.
//

import Foundation
import CoreMIDI

final class MIDIDevice: MIDIObject {
	// MARK: - PROPERTIES
	// MARK: MIDIObject properties
	let objectRef: MIDIObjectRef
	
	// MARK: Stored properties
	private(set) lazy var entities: [MIDIEntity] = retrieveEntities()
	
	// MARK: Computed properties
	var manufacturer: String? {
		return MIDIProperty.manufacturer.value(from: objectRef) as? String
	}
	
	var model: String? {
		return MIDIProperty.model.value(from: objectRef) as? String
	}
	
	
	// MARK: - METHODS
	// MARK: Initialisers
	init(objectRef: MIDIObjectRef) {
		self.objectRef = objectRef
	}
	
	// MARK: MIDI methods
	private func retrieveEntities() -> [MIDIEntity] {
		let entityIndexes = 0 ..< MIDIDeviceGetNumberOfEntities(objectRef)
		let entities: [MIDIEntity] = entityIndexes.map({ entityIndex in
			let entityRef = MIDIDeviceGetEntity(objectRef, entityIndex)
			return MIDIEntity(objectRef: entityRef, device: self)
		})
		
		return entities
	}
}
