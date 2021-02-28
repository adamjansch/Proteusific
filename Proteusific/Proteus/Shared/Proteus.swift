//
//  Proteus.swift
//  Proteusific
//
//  Created by Adam Jansch on 13/12/2020.
//

import AudioKit
import CoreMIDI

typealias BiDirectionalEndpointInfo = (source: EndpointInfo?, destination: EndpointInfo)

final class Proteus {
	// MARK: - PROPERTIES
	// MARK: Shared instance
	static let shared = Proteus()
	
	// MARK: Type properties
	private static let midiOperationQueueLabel = "MIDIOperationQueue"
	static let messageTimeoutDuration: TimeInterval = 1.0
	static let midiOperationQueue = DispatchQueue(label: midiOperationQueueLabel, qos: .utility)
	
	// MARK: Stored properties
	var pendingSysExMessages: [SysExMessage] = []
	var sysExResponseTimer: Timer?
	
	// MARK: Computed properties
	var currentDeviceID: MIDIByte {
		switch User.current?.currentDevice?.deviceID {
		case .some(let deviceID):
			return MIDIByte(deviceID)
			
		case .none:
			return SysExMessage.allBroadcastID
		}
	}
	
	
	// MARK: - METHODS
	// MARK: Initializers
	private init() {}
	
	deinit {
		MIDI.sharedInstance.removeListener(self)
		clearSysExResponseTimer()
	}
	
	// MARK: Configuration methods
	func configure() {
		let midi = MIDI.sharedInstance
		midi.clearListeners()
		midi.addListener(self)
	}
	
	// MARK: MIDI methods
	func changePreset(to preset: Preset, channel: MIDIChannel) {
		let midi = MIDI.sharedInstance
		let channel: MIDIChannel = channel
		
		let romChangeEvent = MIDIEvent(controllerChange: 0, value: MIDIByte(preset.romID), channel: channel)
		midi.sendEvent(romChangeEvent)
		
		let bankNumber = MIDIByte(preset.presetID / 128)
		let bankChangeEvent = MIDIEvent(controllerChange: 32, value: bankNumber, channel: channel)
		midi.sendEvent(bankChangeEvent)
		
		let presetNumber = MIDIByte(preset.presetID % 128)
		let programChangeEvent = MIDIEvent(programChange: presetNumber, channel: channel)
		midi.sendEvent(programChangeEvent)
	}
}
