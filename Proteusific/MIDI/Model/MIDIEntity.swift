//
//  MIDIEntity.swift
//  Proteusific
//
//  Created by Adam Jansch on 11/12/2020.
//

import CoreMIDI

final class MIDIEntity: MIDIObject {
	// MARK: - PROPERTIES
	// MARK: MIDIObject properties
	let objectRef: MIDIObjectRef
	
	// MARK: Stored properties
	weak var device: MIDIDevice?
	private(set) lazy var sourceEndpoints: [MIDIEndpoint] = retrieveSourceEndpoints()
	private(set) lazy var destinationEndpoints: [MIDIEndpoint] = retrieveDestinationEndpoints()
	
	
	// MARK: - METHODS
	// MARK: Initialisers
	init(objectRef: MIDIObjectRef, device: MIDIDevice) {
		self.objectRef = objectRef
		self.device = device
	}
	
	// MARK: MIDI methods
	private func retrieveSourceEndpoints() -> [MIDIEndpoint] {
		let endpointIndexes = 0 ..< MIDIEntityGetNumberOfSources(objectRef)
		let endpoints: [MIDIEndpoint] = endpointIndexes.map({ endpointIndex in
			let endpointRef = MIDIEntityGetSource(objectRef, endpointIndex)
			return MIDIEndpoint(objectRef: endpointRef, entity: self)
		})
		
		return endpoints
	}
	
	private func retrieveDestinationEndpoints() -> [MIDIEndpoint] {
		let endpointIndexes = 0 ..< MIDIEntityGetNumberOfDestinations(objectRef)
		let endpoints: [MIDIEndpoint] = endpointIndexes.map({ endpointIndex in
			let endpointRef = MIDIEntityGetDestination(objectRef, endpointIndex)
			return MIDIEndpoint(objectRef: endpointRef, entity: self)
		})
		
		return endpoints
	}
}
