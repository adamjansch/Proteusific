//
//  ROM+CoreDataClass.swift
//  Proteusific
//
//  Created by Adam Jansch on 08/01/2021.
//
//

import Foundation
import CoreData

final public class ROM: NSManagedObject {
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
		case extremeLead =		14
		case purePhattMP7 =		15
		case beatGarden =		16
		case popCollection =	17
		case extremeLeadV2 =	18
		case purePhattMK6 =		19
		case composerP2500 =	20
		case ensoniqProject =	21
		case soundsOfTheZRHalo = 22
		case vintageCollection = 23
		case proteamDrums =		24
		
		var id: Int32 {
			return rawValue
		}
	}
	
	
	// MARK: - PROPERTIES
	// MARK: Computed properties
	var simm: SIMM {
		return SIMM(rawValue: id) ?? .none
	}
	
	
	// MARK: - METHODS
	// MARK: Initialisers
	convenience init(rom: Proteus.HardwareConfiguation.ROM) {
		self.init(context: PersistenceController.shared.container.viewContext)
		
		self.id = Int32(rom.id)
		self.presetCount = Int32(rom.presetCount)
		self.instrumentCount = Int32(rom.instrumentCount)
	}
}
