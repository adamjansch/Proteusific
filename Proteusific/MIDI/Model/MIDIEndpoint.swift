//
//  MIDIEndpoint.swift
//  Proteusific
//
//  Created by Adam Jansch on 11/12/2020.
//

import CoreMIDI

final class MIDIEndpoint: MIDIObject {
	// MARK: - PROPERTIES
	// MARK: MIDIObject properties
	let objectRef: MIDIObjectRef
	
	// MARK: Stored properties
	weak var entity: MIDIEntity?
	
	
	// MARK: - METHODS
	// MARK: Initialisers
	init(objectRef: MIDIObjectRef, entity: MIDIEntity) {
		self.objectRef = objectRef
		self.entity = entity
	}
}
