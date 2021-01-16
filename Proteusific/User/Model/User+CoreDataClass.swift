//
//  User+CoreDataClass.swift
//  Proteusific
//
//  Created by Adam Jansch on 03/01/2021.
//
//

import Foundation
import CoreData
import AudioKit

final public class User: NSManagedObject {
	// MARK: - PROPERTIES
	// MARK: Type properties
	static var current: User? = {
		guard let entityName = entity().name else {
			return nil
		}
		
		let dataContext = PersistenceController.shared.container.viewContext
		
		do {
			let userFetchRequest = NSFetchRequest<User>(entityName: entityName)
			
			if let firstUser = try dataContext.fetch(userFetchRequest).first {
				return firstUser
				
			} else {
				let newUser = User()
				try dataContext.save()
				return newUser
			}
			
		} catch {
			return nil
		}
	}()
	
	// MARK: Computed properties
	var currentDevice: Device? {
		get {
			guard let currentDeviceUUID = currentDeviceUUID else {
				return nil
			}
			
			return try? Device.fetch(with: currentDeviceUUID)
		}
		set {
			currentDeviceUUID = newValue?.uuid
			try? PersistenceController.shared.container.viewContext.save()
			updateEndpoints(with: newValue)
		}
	}
	
	
	// MARK: - METHODS
	// MARK: Initialisers
	convenience init() {
		let dataContext = PersistenceController.shared.container.viewContext
		
		self.init(context: dataContext)
		self.uuid = UUID()
	}
	
	// MARK: Utility methods
	func updateEndpoints(with device: Device?) {
		let midi = MIDI.sharedInstance
		midi.closeAllInputsAndOutputs()
		
		guard let newDevice = device else {
			return
		}
		
		// Update inputs
		if let sourceEndpointUID = newDevice.sourceEndpointUID,
		   midi.inputInfos.contains(where: { sourceEndpointUID == $0.midiUniqueID }) {
			midi.openInput(uid: sourceEndpointUID)
		}
		
		// Update outputs
		if let destinationEndpointUID = newDevice.destinationEndpointUID,
		   midi.destinationInfos.contains(where: { destinationEndpointUID == $0.midiUniqueID }) {
			midi.openOutput(uid: destinationEndpointUID)
		}
	}
}
