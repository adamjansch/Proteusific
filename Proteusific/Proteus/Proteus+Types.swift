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
	
	enum SIMM: Int32 {
		case none = 			0
		case composer = 		1
		case holyGrailPiano = 	2
		case protozoa = 		3
		case constructionYard =	4
		case definitiveB3 =		5
		case extremeLeadV1 =	6
							//	7
		case orchestralV1 =		8
		case orchestralV2 =		9
		case siedlaczek =		10
		case worldExpedition =	11
		case soundOfTheZR =		12
		case purePhatt =		13
		case extremeLeadXL7 =	14
		case purePhattMP7 =		15
		case beatGarden =		16
		case popCollection =	17
		case extremeLeadV2 =	18
		case purePhattMK6 =		19
		case composerP2500 =	20
		case ensoniqProject =	21
		case soundsOfTheZRHalo = 22
		case vintageCollection = 23
		case proteanDrums =		24
		
		var id: Int32 {
			return rawValue
		}
		
		var name: String {
			switch self {
			case .none:
				return ""
			case .composer:
				return "Composer"
			case .holyGrailPiano:
				return "Holy Grail Piano"
			case .protozoa:
				return "Protozoa"
			case .constructionYard:
				return "Construction Yard"
			case .definitiveB3:
				return "Definitive B-3"
			case .extremeLeadV1:
				return "Extreme Lead V1"
			case .orchestralV1:
				return "Orchestral V1"
			case .orchestralV2:
				return "Orchestral V2"
			case .siedlaczek:
				return "Siedlaczek"
			case .worldExpedition:
				return "World Expedition"
			case .soundOfTheZR:
				return "Sound of the ZR"
			case .purePhatt:
				return "Pure Phatt"
			case .extremeLeadXL7:
				return "Extreme Lead (XL-7)"
			case .purePhattMP7:
				return "Pure Phatt (MP-7)"
			case .beatGarden:
				return "Beat Garden"
			case .popCollection:
				return "Pop Collection"
			case .extremeLeadV2:
				return "Extreme Lead V2"
			case .purePhattMK6:
				return "Pure Phatt (MK-6)"
			case .composerP2500:
				return "Composer (Proteus 2500)"
			case .ensoniqProject:
				return "Ensoniq Project"
			case .soundsOfTheZRHalo:
				return "Sound of the ZR (Halo)"
			case .vintageCollection:
				return "Vintage Collection"
			case .proteanDrums:
				return "Protean Drums"
			}
		}
	}
	
	enum ObjectType: MIDIByte {
		case unknown = 0
		case preset = 1
		case instrument = 2
		case arp = 3
		case setup = 4
		case demo = 5
		case riff = 6
		
		var midiByte: MIDIByte {
			return rawValue
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
		let familyID: MIDIWord
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
			
			let familyMemberBytes = data[8...9].withUnsafeBytes({ $0.load(as: MIDIWord.self) })
			let familyMember = DeviceFamilyMember(rawValue: MIDIWord(familyMemberBytes)) ?? .unknown
			
			self.deviceID = data[2]
			self.familyID = MIDIWord(data[6...7].withUnsafeBytes({ $0.load(as: MIDIWord.self) }))
			self.familyMember = familyMember
			self.softwareVersion = String(data[10...13].map({ Character(UnicodeScalar($0)) }))
			self.sourceEndpointInfo = endpointInfo.source
			self.destinationEndpointInfo = endpointInfo.destination
		}
	}
	
	struct HardwareConfiguation {
		let userPresetCount: MIDIWord
		let roms: [ROM]
		
		// MARK: - METHODS
		// MARK: Initialisers
		init(data: [MIDIByte]) throws {
			/*
			BYTES (by index)
			0:		Sysex message
			1:		EMU ID
			2:		Proteus ID
			3:		Device ID
			4:		Special Editor byte
			5:		Command
			6:		General Information byte count
			7-8:	General Information bytes { Preset count }
			9:		ROM count
			10:		SIMM Information byte count
			
			End:	EOX
			*/
			
			guard data[0] == SysExMessage.sysExMessageByte,
				  data[1] == SysExMessage.sysExEMUByte,
				  data[2] == SysExMessage.sysExProteusByte,
				  data[4] == SysExMessage.sysExSpecialEditorByte,
				  data[5] == SysExMessage.Command.hardwareConfigurationResponse.byte else {
				throw Error.incompatibleSysExMessage(data: data)
			}
			
			var byteOffset = 6
			let generalInfoByteCount = data[byteOffset]
			byteOffset += 1
			
			let userPresetCountBytes = Array(data[byteOffset...byteOffset + 1])
			self.userPresetCount = try MIDIWord(processedMIDIBytes: userPresetCountBytes)
			byteOffset += Int(generalInfoByteCount)
			
			let romCount = data[byteOffset]
			byteOffset += 1
			
			//let romInformationByteCount = data[byteOffset]
			byteOffset += 1
			
			var roms: [ROM] = []
			
			for _ in 0..<romCount {
				let romIDBytes = Array(data[byteOffset...byteOffset + 1])
				let romID = try MIDIWord(processedMIDIBytes: romIDBytes)
				byteOffset += MIDIWord.byteCount
				
				let romPresetCountBytes = Array(data[byteOffset...byteOffset + 1])
				let romPresetCount = try MIDIWord(processedMIDIBytes: romPresetCountBytes)
				byteOffset += MIDIWord.byteCount
				
				let romInstrumentCountBytes = Array(data[byteOffset...byteOffset + 1])
				let romInstrumentCount = try MIDIWord(processedMIDIBytes: romInstrumentCountBytes)
				byteOffset += MIDIWord.byteCount
				
				let rom = ROM(id: romID, presetCount: romPresetCount, instrumentCount: romInstrumentCount)
				roms.append(rom)
			}
			
			self.roms = roms
		}
	}
}

extension Proteus.HardwareConfiguation {
	struct ROM {
		let id: UInt16
		let presetCount: UInt16
		let instrumentCount: UInt16
	}
}
