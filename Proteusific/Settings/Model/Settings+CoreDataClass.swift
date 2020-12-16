//
//  Settings+CoreDataClass.swift
//  Proteusific
//
//  Created by Adam Jansch on 09/12/2020.
//
//

import CoreData
import AudioKit

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
	var midiInEndpointInfo: EndpointInfo? {
		get {
			guard let uid = midiInUID else {
				return nil
			}
			
			return MIDI.sharedInstance.inputInfos.first(where: { $0.midiUniqueID == uid.int32Value })
		}
		set {
			guard let endpointInfo = newValue else {
				midiInUID = nil
				return
			}
			
			switch endpointInfo.midiUniqueID {
			case 0:
				midiInUID = nil
			default:
				midiInUID = NSNumber(value: endpointInfo.midiUniqueID)
			}
		}
	}
	
	var midiOutEndpointInfo: EndpointInfo? {
		get {
			guard let uid = midiOutUID else {
				return nil
			}
			
			return MIDI.sharedInstance.destinationInfos.first(where: { $0.midiUniqueID == uid.int32Value })
		}
		set {
			// First, close the output using the current output unique ID (if present)
			if let uid = midiOutUID {
				MIDI.sharedInstance.closeOutput(uid: uid.int32Value)
			}
			
			guard let endpointInfo = newValue else {
				midiOutUID = nil
				return
			}
			
			switch endpointInfo.midiUniqueID {
			case 0:
				midiOutUID = nil
			default:
				midiOutUID = NSNumber(value: endpointInfo.midiUniqueID)
			}
			
			// Last, open the output using the current output unique ID (if present)
			if let uid = midiOutUID {
				MIDI.sharedInstance.openOutput(uid: uid.int32Value)
			}
		}
	}
	
	
	// MARK: - METHODS
	// MARK: Initialisers
	convenience init() {
		self.init(context: PersistenceController.shared.container.viewContext)
	}
}