//
//  Proteus+SysExMessage.swift
//  Proteusific
//
//  Created by Adam Jansch on 13/12/2020.
//

import AudioKit

typealias MIDIResponseAction = (Result<[MIDIByte], Proteus.Error>) -> Void

extension Proteus {
	// MARK: - ENUMS
	// MARK: MIDI enums
	enum SysExMessage {
		enum MessageType {
			case universal
			case proteus
			
			var sysExHeader: [MIDIByte] {
				switch self {
				case .universal:
					return [
						sysExMessageByte,
						sysExHeaderByte,
						Proteus.shared.currentDeviceID,
						sysExGeneralInformationByte
					]
					
				case .proteus:
					return [
						sysExMessageByte,
						sysExEMUByte,
						sysExProteusByte,
						Proteus.shared.currentDeviceID,
						sysExSpecialEditorByte
					]
				}
			}
			
			var byteMatchMask: [Bool] {
				switch self {
				case .universal:
					return [true, true, false, true, true]
				case .proteus:
					return [true, true, true, false, true, true]
				}
			}
		}
		
		
		// MARK: - CASES
		case deviceIdentity(responseAction: MIDIResponseAction)
		case presetDumpClosedLoop(responseAction: MIDIResponseAction)
		
		
		// MARK: - PROPERTIES
		// MARK: Type properties
		static let allBroadcastID: MIDIByte = 127
		
		static let sysExMessageByte: MIDIByte = 0xF0
		static let sysExHeaderByte: MIDIByte = 0x7E
		private static let sysExGeneralInformationByte: MIDIByte = 0x06
		private static let sysExSpecialEditorByte: MIDIByte = 0x55
		private static let sysExEMUByte: MIDIByte = 0x18
		private static let sysExProteusByte: MIDIByte = 0x0F
		private static let eoxByte: MIDIByte = 0xF7
		
		// MARK: Computed properties
		var messageType: MessageType {
			switch self {
			case .deviceIdentity:
				return .universal
				
			case .presetDumpClosedLoop:
				return .proteus
			}
		}
		
		var requestCommand: [MIDIByte] {
			let sysExHeader = messageType.sysExHeader
			
			switch self {
			case .deviceIdentity:
				return sysExHeader + requestCommandBytes + [Self.eoxByte]
				
			case .presetDumpClosedLoop:
				return sysExHeader + [
					0x11,		// Command: Preset Dump
					0x02,		// Subcommand: Preset Dump Request (Closed Loop)
					0x7F, 0x7F,	// Preset number
					0x00, 0x00, // Preset ROM ID
					Self.eoxByte
				]
			}
		}
		
		var responseAction: MIDIResponseAction {
			switch self {
			case .deviceIdentity(let responseAction),
				 .presetDumpClosedLoop(let responseAction):
				return responseAction
			}
		}
		
		private var requestCommandBytes: [MIDIByte] {
			switch self {
			case .deviceIdentity:
				return [0x01]
			case .presetDumpClosedLoop:
				return [0x10, 0x01]
			}
		}
		
		private var responseCommandBytes: [MIDIByte] {
			switch self {
			case .deviceIdentity:
				return [0x02]
			case .presetDumpClosedLoop:
				return [0x11, 0x02]
			}
		}
		
		
		// MARK: - METHODS
		// MARK: Type methods
		func matches(data: [MIDIByte]) -> Bool {
			for (dataByteIndex, dataByte) in data.enumerated() {
				let matchMessage = messageType.sysExHeader + responseCommandBytes
				
				guard let shouldMatchByte = messageType.byteMatchMask[safe: dataByteIndex],
					  shouldMatchByte,
					  let matchByte = matchMessage[safe: dataByteIndex] else {
					continue
				}
				
				if matchByte != dataByte {
					return false
				}
			}
			
			return true
		}
	}
}


// MARK: - PROTOCOL CONFORMANCE
extension Proteus.SysExMessage: Identifiable {
	// MARK: Identifiable
	var id: [MIDIByte] {
		switch self {
		case .deviceIdentity:
			return [Self.sysExGeneralInformationByte] + requestCommandBytes
		case .presetDumpClosedLoop:
			return [Self.sysExSpecialEditorByte] + requestCommandBytes
		}
	}
}

extension Proteus.SysExMessage: Equatable {
	static func == (lhs: Proteus.SysExMessage, rhs: Proteus.SysExMessage) -> Bool {
		return lhs.id == rhs.id
	}
}
