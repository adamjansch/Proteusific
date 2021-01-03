//
//  Proteus+Types.swift
//  Proteusific
//
//  Created by Adam Jansch on 16/12/2020.
//

import AudioKit

extension Proteus {
	// MARK: - ENUMS
	// MARK: DeviceFamily
	enum DeviceFamilyMember: MIDIWord {
		case unknown = 0x00
		case audity2000 = 0x02
		case proteus2000 = 0x03
		case b3 = 0x04
		case xl1 = 0x05
		case virtuoso2000 = 0x06
		case moPhatt = 0x07
		case b3Turbo = 0x08
		case xl1Turbo = 0x09
		case turboPhatt = 0x0a
		case planetEarth = 0x0b
		case planetEarthTurbo = 0x0c
		case xl7 = 0x0d
		case mp7 = 0x0e
		case proteus2500 = 0x0f
		case orbit3 = 0x10
		case pk6 = 0x11
		case xk6 = 0x12
		case mk6 = 0x13
		case halo = 0x14
		case proteus1000 = 0x15
		case vintagePro = 0x16
		case vintageKeys = 0x17
		case px7 = 0x18
		
		var name: String {
			switch self {
			case .unknown:
				return "Unknown"
			case .audity2000:
				return "Audity 2000"
			case .proteus2000:
				return "Proteus 2000"
			case .b3:
				return "B-3"
			case .xl1:
				return "XL-1"
			case .virtuoso2000:
				return "Virtuoso 2000"
			case .moPhatt:
				return "Mo'Phatt"
			case .b3Turbo:
				return "B-3 Turbo"
			case .xl1Turbo:
				return "XL-1 Turbo"
			case .turboPhatt:
				return "Turbo Phatt"
			case .planetEarth:
				return "Planet Earth"
			case .planetEarthTurbo:
				return "Planet Earth Turbo"
			case .xl7:
				return "XL-7"
			case .mp7:
				return "MP-7"
			case .proteus2500:
				return "Proteus 2500"
			case .orbit3:
				return "Orbit-3"
			case .pk6:
				return "PK-6"
			case .xk6:
				return "XK-6"
			case .mk6:
				return "MK-6"
			case .halo:
				return "Halo"
			case .proteus1000:
				return "Proteus 1000"
			case .vintagePro:
				return "Vintage Pro"
			case .vintageKeys:
				return "Vintage Keys"
			case .px7:
				return "PX-7"
			}
		}
	}
	
	
	// MARK: - STRUCTS
	// MARK: DeviceIdentity
	struct DeviceIdentity: Identifiable, Equatable {
		// MARK: - PROPERTIES
		// MARK: Identifiable properties
		var id: MIDIByte {
			return deviceID
		}
		
		// MARK: Stored properties
		let deviceID: MIDIByte
		let familyID: UInt16
		let familyMember: DeviceFamilyMember
		let softwareVersion: String
		
		let sourceEndpointInfo: EndpointInfo?
		let destinationEndpointInfo: EndpointInfo
		
		
		// MARK: - METHODS
		// MARK: Initialisers
		init(data: [MIDIByte], endpointInfo: BiDirectionalEndpointInfo) throws {
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
			
			let familyMemberBytes = data[8...9].withUnsafeBytes({ $0.load(as: UInt16.self) })
			let familyMember = DeviceFamilyMember(rawValue: MIDIWord(familyMemberBytes)) ?? .unknown
			
			self.deviceID = data[2]
			self.familyID = UInt16(data[6...7].withUnsafeBytes({ $0.load(as: UInt16.self) }))
			self.familyMember = familyMember
			self.softwareVersion = String(data[10...13].map({ Character(UnicodeScalar($0)) }))
			self.sourceEndpointInfo = endpointInfo.source
			self.destinationEndpointInfo = endpointInfo.destination
		}
	}
}
