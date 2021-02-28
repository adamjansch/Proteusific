//
//  Preset+CoreDataClass.swift
//  Proteusific
//
//  Created by Adam Jansch on 24/01/2021.
//
//

import CoreData
import AudioKit

final public class Preset: NSManagedObject, ProteusObject {
	// MARK: - PROPERTIES
	// MARK: ProteusObject properties
	var objectType: Proteus.ObjectType {
		return .preset
	}
	
	var category: Proteus.PresetCategory {
		get {
			let categoryString = storedCategory ?? ""
			return Proteus.PresetCategory(rawValue: categoryString) ?? .unknown
		}
		set {
			storedCategory = newValue.rawValue
		}
	}
	
	// MARK: Computed properties
	var presetID: MIDIWord {
		get {
			return MIDIWord(storedObjectID)
		}
		set {
			storedObjectID = Int16(newValue)
		}
	}
	
	var simm: Proteus.SIMM {
		get {
			return Proteus.SIMM(rawValue: romID) ?? .unknown
		}
		set {
			romID = newValue.id
		}
	}
	
	
	// MARK: - METHODS
	// MARK: Type methods
	static func fetch(with presetID: Int16) throws -> Preset? {
		guard let entityName = entity().name else {
			return nil
		}
		
		let presetFetchRequest = NSFetchRequest<Preset>(entityName: entityName)
		let presetFetchPredicate = NSPredicate(format: "storedObjectID == %ld", presetID)
		presetFetchRequest.predicate = presetFetchPredicate
		
		return try PersistenceController.shared.container.viewContext.fetch(presetFetchRequest).first
	}
	
	// MARK: Initializers
	convenience init(genericName: Proteus.GenericName) throws {
		guard genericName.type == .preset else {
			throw Proteus.Error.invalidObjectType(genericName.type)
		}
		
		self.init(context: PersistenceController.shared.container.viewContext)
		
		self.storedObjectID = Int16(genericName.objectID)
		self.romID = genericName.simm.id
		self.storedCategory = genericName.category.rawValue
		self.title = genericName.title
	}
}
