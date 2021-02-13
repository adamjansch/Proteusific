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
		return Proteus.SIMM(rawValue: id) ?? .unknown
	}
	
	var presets: [Preset] {
		let presetSortDescriptor = NSSortDescriptor(keyPath: \Preset.storedObjectID, ascending: true)
		return storedPresets?.sortedArray(using: [presetSortDescriptor]) as? [Preset] ?? []
	}
	
	
	// MARK: - METHODS
	// MARK: Type methods
	static func fetch(with romID: Int16) throws -> ROM? {
		guard let entityName = entity().name else {
			return nil
		}
		
		let romFetchRequest = NSFetchRequest<ROM>(entityName: entityName)
		let romFetchPredicate = NSPredicate(format: "storedObjectID == %@", romID as CVarArg)
		romFetchRequest.predicate = romFetchPredicate
		
		return try PersistenceController.shared.container.viewContext.fetch(romFetchRequest).first
	}
	
	// MARK: Initialisers
	convenience init(rom: Proteus.HardwareConfiguation.ROM) {
		self.init(context: PersistenceController.shared.container.viewContext)
		
		self.id = Int32(rom.id)
		self.presetCount = Int32(rom.presetCount)
		self.instrumentCount = Int32(rom.instrumentCount)
	}
}
