//
//  Proteus+Types.swift
//  Proteusific
//
//  Created by Adam Jansch on 16/12/2020.
//

import AudioKit

extension Proteus {
	// MARK: - DeviceIdentity
	struct DeviceIdentity {
		// MARK: - PROPERTIES
		// MARK: Stored properties
		let deviceID: MIDIByte
		let familyID: UInt16
		let familyMemberID: UInt16
		let softwareVersion: String
		
		
		// MARK: - METHODS
		// MARK: Initialisers
		init(data: [MIDIByte]) throws {
			/*
			BYTES (by index)
			0:		Sysex message
			1:		Sysex header byte 2
			2:		Device ID
			3:		General Information
			4:		Command - should be 2
			5:		Manufacturer Sysex ID
			6-7:	Device family (14 bits, LSB first)
			8-9:	Device family member (14 bits, LSB first)
			10-13:	Software revision level (4 ASCII characters)
			14:		EOX
			*/
			
			guard data[0] == SysExMessage.sysExMessageByte,
				  data[1] == SysExMessage.sysExHeaderByte else {
				throw Error.incompatibleSysExMessage(data: data)
			}
			
			deviceID = data[2]
			familyID = UInt16(data[6...7].withUnsafeBytes({ $0.load(as: UInt16.self) }))
			familyMemberID = UInt16(data[8...9].withUnsafeBytes({ $0.load(as: UInt16.self) }))
			softwareVersion = String(data[10...13].map({ Character(UnicodeScalar($0)) }))
		}
	}
}
