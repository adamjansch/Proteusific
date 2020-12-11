//
//  Settings+CoreDataClass.swift
//  Proteusific
//
//  Created by Adam Jansch on 09/12/2020.
//
//

import CoreData
import CoreMIDI

public class Settings: NSManagedObject {
	// MARK: - PROPERTIES
	// MARK: Shared instance
	static let current: Settings = {
		let settingsFetchRequest = NSFetchRequest<Settings>(entityName: name)
		let allSettings = try? PersistenceController.shared.container.viewContext.fetch(settingsFetchRequest)
		
		switch allSettings?.first {
		case .some(let settings):
			return settings
			
		case .none:
			let newSettings = Settings()
			PersistenceController.shared.container.saveContext()
			
			return newSettings
		}
	}()
	
	// MARK: Type properties
	static let name = "Settings"
	
	// MARK: Computed properties
	var midiInDevice: MIDIDevice? {
		return midiDevice(for: midiInDeviceID)
	}
	
	var midiOutDevice: MIDIDevice? {
		return midiDevice(for: midiOutDeviceID)
	}
	
	
	// MARK: - METHODS
	// MARK: Initialisers
	convenience init() {
		self.init(context: PersistenceController.shared.container.viewContext)
	}
	
	// MARK: Utilities methods
	private func midiDevice(for deviceID: NSNumber?) -> MIDIDevice? {
		guard let deviceID = deviceID else {
			return nil
		}
		
		var objectRef = MIDIObjectRef()
		var objectType = MIDIObjectType.other
		let status = MIDIObjectFindByUniqueID(deviceID.int32Value, &objectRef, &objectType)
		
		guard status == noErr,
			  objectType == .device else {
			return nil
		}
		
		return MIDIDevice(objectRef: objectRef)
	}
}
