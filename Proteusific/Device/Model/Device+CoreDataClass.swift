//
//  Device+CoreDataClass.swift
//  Proteusific
//
//  Created by Adam Jansch on 16/12/2020.
//
//

import CoreData
import AudioKit

public class Device: NSManagedObject {
	// MARK: - PROPERTIES
	// MARK: Type properties
	static let name = "Device"
	
	
	// MARK: - METHODS
	// MARK: Type methods
	static func fetch(with deviceIdentity: Proteus.DeviceIdentity) -> Device? {
		let devicesFetchRequest = NSFetchRequest<Device>(entityName: name)
		
		guard let allDevices = try? PersistenceController.shared.container.viewContext.fetch(devicesFetchRequest) else {
			return nil
		}
		
		let matchingDevices = allDevices.filter({
			guard $0.deviceID == deviceIdentity.deviceID,
				  $0.familyID == deviceIdentity.familyID,
				  $0.familyMemberID == deviceIdentity.familyMemberID else {
				return false
			}
			
			return true
		})
		
		return matchingDevices.first
	}
	
	// MARK: Initialisers
	convenience init(deviceIdentity: Proteus.DeviceIdentity, name: String?) {
		self.init(context: PersistenceController.shared.container.viewContext)
		
		deviceID = Int16(deviceIdentity.deviceID)
		familyID = Int32(deviceIdentity.familyID)
		familyMemberID = Int32(deviceIdentity.familyMemberID)
		softwareVersion = deviceIdentity.softwareVersion
		customName = name
	}
}
