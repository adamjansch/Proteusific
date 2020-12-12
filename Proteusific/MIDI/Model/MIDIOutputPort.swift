//
//  MIDIOutputPort.swift
//  Proteusific
//
//  Created by Adam Jansch on 11/12/2020.
//

import CoreMIDI

struct MIDIOutputPort {
	// MARK: - PROPERTIES
	// MARK: Stored properties
	let portRef: MIDIPortRef
	
	
	// MARK: - METHODS
	// MARK: Initialisers
	init(clientRef: MIDIClientRef, name: String? = nil) throws {
		let portName = name ?? "Output Port"
		var portRef = MIDIPortRef()
		
		let status = MIDIOutputPortCreate(clientRef, portName as CFString, &portRef)
		guard status == noErr else {
			throw MIDIError.midiPortCreateFailed(status: status)
		}
		
		self.portRef = portRef
	}
}
