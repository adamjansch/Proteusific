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
			guard let deviceID = midiInDeviceID else {
				return nil
			}
			
			return MIDI.sharedInstance.inputInfos.first(where: { $0.midiUniqueID == deviceID.int32Value })
		}
		set {
			guard let endpointInfo = newValue else {
				midiInDeviceID = nil
				return
			}
			
			switch endpointInfo.midiUniqueID {
			case 0:
				midiInDeviceID = nil
			default:
				midiInDeviceID = NSNumber(value: endpointInfo.midiUniqueID)
			}
		}
	}
	
	var midiOutEndpointInfo: EndpointInfo? {
		get {
			guard let deviceID = midiOutDeviceID else {
				return nil
			}
			
			return MIDI.sharedInstance.destinationInfos.first(where: { $0.midiUniqueID == deviceID.int32Value })
		}
		set {
			// First, close the output using the current output unique ID (if present)
			if let outputUniqueID = midiOutDeviceID {
				MIDI.sharedInstance.closeOutput(uid: outputUniqueID.int32Value)
			}
			
			guard let endpointInfo = newValue else {
				midiOutDeviceID = nil
				return
			}
			
			switch endpointInfo.midiUniqueID {
			case 0:
				midiOutDeviceID = nil
			default:
				midiOutDeviceID = NSNumber(value: endpointInfo.midiUniqueID)
			}
			
			// Last, open the output using the current output unique ID (if present)
			if let outputUniqueID = midiOutDeviceID {
				MIDI.sharedInstance.openOutput(uid: outputUniqueID.int32Value)
			}
		}
	}
	
	
	// MARK: - METHODS
	// MARK: Initialisers
	convenience init() {
		self.init(context: PersistenceController.shared.container.viewContext)
	}
}
