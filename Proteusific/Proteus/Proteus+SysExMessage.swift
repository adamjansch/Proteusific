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
	enum SysExMessage {
		case deviceIdentity
		case presetDump(deviceID: MIDIByte)
		
		static let allBroadcastID: MIDIByte = 127
		
		static let sysExMessageByte: MIDIByte = 0xF0
		static let sysExHeaderByte: MIDIByte = 0x7E
		private static let sysExDevicePlaceholderByte: MIDIByte = 0xFF
		private static let sysExGeneralInformationByte: MIDIByte = 0x06
		private static let eoxByte: MIDIByte = 0xF7
		
		private static let universalSysExHEader: [MIDIByte] = [
			sysExMessageByte,
			sysExHeaderByte,
			sysExDevicePlaceholderByte,
			sysExGeneralInformationByte
		]
		
		private static let proteusSysExHeader: [MIDIByte] = [
			sysExMessageByte,
			0x18,	// EMU ID
			0x0F,	// Proteus ID
			sysExDevicePlaceholderByte,		// Device ID: This will be replaced before sending
			0x55,	// Special Editor designator byte
		]
		
		var requestCommand: [MIDIByte] {
			switch self {
			case .deviceIdentity:
				var universalHeader = Self.universalSysExHEader
				if let deviceIDIndex = universalHeader.firstIndex(of: Self.sysExDevicePlaceholderByte) {
					universalHeader[deviceIDIndex] = Proteus.shared.currentDeviceID
				}
				
				return universalHeader + [
					requestCommandByte,
					Self.eoxByte
				]
				
			case .presetDump:
				var proteusHeader = Self.proteusSysExHeader
				if let deviceIDIndex = proteusHeader.firstIndex(of: Self.sysExDevicePlaceholderByte) {
					proteusHeader[deviceIDIndex] = Proteus.shared.currentDeviceID
				}
				
				return proteusHeader + [
					0x11,		// Command: Preset Dump
					0x02,		// Subcommand: Preset Dump Request (Closed Loop)
					0x7F, 0x7F,	// Preset number
					0x00, 0x00, // Preset ROM ID
					Self.eoxByte
				]
			}
		}
		
		private var requestCommandByte: MIDIByte {
			switch self {
			case .deviceIdentity:
				return 0x01
			default:
				return 0x00
			}
		}
		
		private var responseCommandByte: MIDIByte {
			switch self {
			case .deviceIdentity:
				return 0x02
			default:
				return 0x00
			}
		}
	}
}
