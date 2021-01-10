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
	// MARK: - PROPERTIES
	// MARK: Computed properties
	var simm: Proteus.SIMM {
		return Proteus.SIMM(rawValue: id) ?? .none
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
