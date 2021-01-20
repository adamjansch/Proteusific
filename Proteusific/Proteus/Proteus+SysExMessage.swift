//
//  Proteus+SysExMessage.swift
//  Proteusific
//
//  Created by Adam Jansch on 13/12/2020.
//

import AudioKit

typealias MIDIResponseResult = Result<Proteus.DeviceIdentity, Proteus.Error>
typealias MIDIResponseAction = (Result<[MIDIByte], Proteus.Error>) -> Void

extension Proteus {
	// MARK: - ENUMS
	// MARK: MIDI enums
	enum SysExMessage {
		// MARK: - CASES
		case deviceIdentity(responseAction: MIDIResponseAction)
		case genericName(type: Proteus.ObjectType, objectID: MIDIWord, romID: MIDIWord, responseAction: MIDIResponseAction)
		case hardwareConfiguration(responseAction: MIDIResponseAction)
		case presetDumpClosedLoop(responseAction: MIDIResponseAction)
		
		
		// MARK: - PROPERTIES
		// MARK: Type properties
		static let allBroadcastID: MIDIByte = 127
		
		static let sysExMessageByte: MIDIByte = 0xF0
		static let sysExHeaderByte: MIDIByte = 0x7E
		static let sysExEMUByte: MIDIByte = 0x18
		static let sysExProteusByte: MIDIByte = 0x0F
		static let sysExSpecialEditorByte: MIDIByte = 0x55
		private static let sysExGeneralInformationByte: MIDIByte = 0x06
		static let eoxByte: MIDIByte = 0xF7
		
		// MARK: Computed properties
		var messageType: MessageType {
			switch self {
			case .deviceIdentity:
				return .universal
				
			case .genericName,
				 .hardwareConfiguration,
				 .presetDumpClosedLoop:
				return .proteus
			}
		}
		
		var requestCommand: [MIDIByte] {
			let sysExHeader = messageType.sysExHeader
			
			switch self {
			case .deviceIdentity,
				 .hardwareConfiguration:
				return sysExHeader + requestCommandBytes + [Self.eoxByte]
				
			case .genericName(let objectType, let objectID, let romID, _):
				let genericNameBytes: [MIDIByte] = [objectType.midiByte] + objectID.processedMIDIBytes + romID.processedMIDIBytes
				return sysExHeader + requestCommandBytes + genericNameBytes + [Self.eoxByte]
				
			case .presetDumpClosedLoop:
				return sysExHeader + [
					Command.presetDumpRequest.byte,		// Command: Preset Dump
					0x02,		// Subcommand: Preset Dump Request (Closed Loop)
					0x7F, 0x7F,	// Preset number
					0x00, 0x00, // Preset ROM ID
					Self.eoxByte
				]
			}
		}
		
		var expectsMultipleMessages: Bool {
			switch self {
			case .deviceIdentity,
				 .genericName,
				 .hardwareConfiguration:
				return false
			case .presetDumpClosedLoop:
				return true
			}
		}
		
		var responseAction: MIDIResponseAction {
			switch self {
			case .deviceIdentity(let responseAction),
				 .genericName(_, _, _, let responseAction),
				 .hardwareConfiguration(let responseAction),
				 .presetDumpClosedLoop(let responseAction):
				return responseAction
			}
		}
		
		private var requestCommandBytes: [MIDIByte] {
			switch self {
			case .deviceIdentity:
				return [0x01]
			case .genericName:
				return [Command.genericNameRequest.byte]
			case .hardwareConfiguration:
				return [Command.hardwareConfigurationRequest.byte]
			case .presetDumpClosedLoop:
				return [Command.presetDumpRequest.byte, 0x01]
			}
		}
		
		private var responseCommandBytes: [MIDIByte] {
			switch self {
			case .deviceIdentity:
				return [0x02]
			case .genericName:
				return [Command.genericNameResponse.byte]
			case .hardwareConfiguration:
				return [Command.hardwareConfigurationResponse.byte]
			case .presetDumpClosedLoop:
				return [Command.presetDumpResponse.byte, 0x02]
			}
		}
		
		
		// MARK: - METHODS
		// MARK: Type methods
		func matches(data: [MIDIByte]) -> Bool {
			let matchMessage = messageType.sysExHeader + responseCommandBytes
			
			for (dataByteIndex, dataByte) in data.enumerated() {
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
		case .genericName,
			 .hardwareConfiguration,
			 .presetDumpClosedLoop:
			return [Self.sysExSpecialEditorByte] + requestCommandBytes
		}
	}
}

extension Proteus.SysExMessage: Equatable {
	static func == (lhs: Proteus.SysExMessage, rhs: Proteus.SysExMessage) -> Bool {
		return lhs.id == rhs.id
	}
}


// MARK: - ENUMS
extension Proteus.SysExMessage {
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
	
	enum Command: MIDIByte {
		case hardwareConfigurationResponse = 0x09
		case hardwareConfigurationRequest = 0x0A
		case genericNameResponse = 0x0B
		case genericNameRequest = 0x0C
		case presetDumpResponse = 0x10
		case presetDumpRequest = 0x11
		
		var byte: MIDIByte {
			return rawValue
		}
	}
}
