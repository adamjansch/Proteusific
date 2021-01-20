//
//  Proteus+Enums.swift
//  Proteusific
//
//  Created by Adam Jansch on 20/01/2021.
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
	
	enum PresetCategory: String {
		case ambient = 		"amb"
		case arpeggiated =	"arp"
		case bass =			"bas"
		case bpm =			"bpm"
		case brass =		"brs"
		case guitar =		"gtr"
		case hit =			"hit"
		case keyboard =		"key"
		case drumKit =		"kit"
		case lead =			"led"
		case pad =			"pad"
		case rom =			"rom"
		case sfx =			"sfx"
		case strings =		"str"
		case synthesizer =	"syn"
		case vocals =		"vox"
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
}
