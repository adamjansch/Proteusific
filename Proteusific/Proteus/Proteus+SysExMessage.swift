//
//  Proteus+SysExMessage.swift
//  Proteusific
//
//  Created by Adam Jansch on 13/12/2020.
//

import AudioKit

extension Proteus {
	// MARK: - ENUMS
	// MARK: MIDI enums
	enum SysexMessage {
		case deviceInquiry(deviceID: MIDIByte?)
		case presetDump(deviceID: MIDIByte)
		
		static let allBroadcastID: MIDIByte = 127
		private static let sysExMessageByte: MIDIByte = 0xF0
		private static let eox: MIDIByte = 0xF7
		private static let proteusHeader: [MIDIByte] = [
			sysExMessageByte,
			0x18,	// EMU ID
			0x0F,	// Proteus ID
			0x7F,	// Device ID - may be changed later
			0x55,	// Special Editor designator byte
		]
		
		var midiBytes: [MIDIByte] {
			switch self {
			case .deviceInquiry(let deviceID):
				let deviceID = deviceID ?? Self.allBroadcastID
				return [
					Self.sysExMessageByte,
					0x7E,
					deviceID,
					0x06,	// General information
					0x01,	// Identity request
					Self.eox
				]
				
			case .presetDump(let deviceID):
				var messageHeader = Self.proteusHeader
				messageHeader[3] = deviceID
				
				return messageHeader + [
					0x11,		// Command: Preset Dump
					0x02,		// Subcommand: Preset Dump Request (Closed Loop)
					0x7F, 0x7F,	// Preset number
					0x00, 0x00, // Preset ROM ID
					Self.eox
				]
			}
		}
	}
}
