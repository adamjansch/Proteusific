//
//  Proteus+Structs.swift
//  Proteusific
//
//  Created by Adam Jansch on 16/12/2020.
//

import AudioKit

extension Proteus {
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
	
	// MARK: Generic Name
	struct GenericName {
		// MARK: - PROPERTIES
		// MARK: Stored properties
		let type: ObjectType
		let objectID: MIDIWord
		let simm: SIMM
		
		let category: PresetCategory
		let title: String
		
		
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
			6:		Object Type (Proteus.ObjectType)
			7-8:	Object ID
			9-10:	ROM ID
			11-:	Name (ASCII chars)
			End:	EOX
			*/
			
			guard data[0] == SysExMessage.sysExMessageByte,
				  data[1] == SysExMessage.sysExEMUByte,
				  data[2] == SysExMessage.sysExProteusByte,
				  data[4] == SysExMessage.sysExSpecialEditorByte,
				  data[5] == SysExMessage.Command.genericNameResponse.byte else {
				throw Error.incompatibleSysExMessage(data: data)
			}
			
			guard let objectType = ObjectType(rawValue: data[6]),
				  objectType != .unknown else {
				throw Error.sysExMessageObjectTypeNotFound(midiBytes: data)
			}
			
			self.type = objectType
			self.objectID = try MIDIWord(unprocessedMIDIBytes: Array(data[7...8]))
			
			let romID = try MIDIWord(unprocessedMIDIBytes: Array(data[9...10]))
			self.simm = SIMM(rawValue: Int32(romID)) ?? .unknown
			
			// Process the retrieved title to separate the category and actual title
			switch data.firstIndex(of: SysExMessage.eoxByte) {
			case .some(let eoxIndex):
				let rawTitle = String(data[11..<eoxIndex].map({ Character(UnicodeScalar($0)) })).trimmingCharacters(in: .whitespacesAndNewlines)
				let separatorIndex = rawTitle.index(rawTitle.startIndex, offsetBy: 3)
				let separator = rawTitle[separatorIndex]
				
				if separator == ":" {
					let categoryString = String(rawTitle[..<separatorIndex])
					let category = PresetCategory(rawValue: categoryString) ?? .unknown
					self.category = category
					
					let titleStartIndex = rawTitle.index(after: separatorIndex)
					self.title = String(rawTitle[titleStartIndex..<rawTitle.endIndex])
					
				} else {
					self.category = .unknown
					self.title = rawTitle
				}
				
			case .none:
				self.category = .unknown
				self.title = ""
			}
		}
	}
}

extension Proteus {
	// MARK: - HARDWARE CONFIGURATION
	struct HardwareConfiguation {
		// MARK: - PROPERTIES
		// MARK: Stored properties
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
			self.userPresetCount = try MIDIWord(unprocessedMIDIBytes: userPresetCountBytes)
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
				let romPresetCount = try MIDIWord(unprocessedMIDIBytes: romPresetCountBytes)
				byteOffset += MIDIWord.byteCount
				
				let romInstrumentCountBytes = Array(data[byteOffset...byteOffset + 1])
				let romInstrumentCount = try MIDIWord(unprocessedMIDIBytes: romInstrumentCountBytes)
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
		let id: MIDIWord
		let presetCount: MIDIWord
		let instrumentCount: MIDIWord
	}
}
