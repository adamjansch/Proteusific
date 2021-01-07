//
//  Device+CoreDataClass.swift
//  Proteusific
//
//  Created by Adam Jansch on 16/12/2020.
//
//

import CoreData
import AudioKit
import CoreMIDI

final public class Device: NSManagedObject {
	// MARK: - PROPERTIES
	// MARK: Computed properties
	var familyMember: Proteus.DeviceFamilyMember {
		get {
			return Proteus.DeviceFamilyMember(rawValue: MIDIWord(storedFamilyMember)) ?? .unknown
		}
		set {
			storedFamilyMember = Int32(newValue.rawValue)
		}
	}
	
	var sourceEndpointUID: MIDIUniqueID? {
		get {
			switch storedInEndpointUID {
			case .some(let storedInEndpointUID):
				return storedInEndpointUID.int32Value
			case .none:
				return nil
			}
		}
		set {
			switch newValue {
			case .some(let inEndpointUID):
				storedInEndpointUID = NSNumber(value: inEndpointUID)
			case .none:
				storedInEndpointUID = nil
			}
		}
	}
	
	var destinationEndpointUID: MIDIUniqueID? {
		get {
			switch storedOutEndpointUID {
			case .some(let storedOutEndpointUID):
				return storedOutEndpointUID.int32Value
			case .none:
				return nil
			}
		}
		set {
			switch newValue {
			case .some(let outEndpointUID):
				storedOutEndpointUID = NSNumber(value: outEndpointUID)
			case .none:
				storedOutEndpointUID = nil
			}
		}
	}
	
	var sourceEndpointInfo: EndpointInfo? {
		get {
			return MIDI.sharedInstance.inputInfos.first(where: { $0.midiUniqueID == sourceEndpointUID })
		}
		set {
			sourceEndpointUID = newValue?.midiUniqueID
		}
	}
	
	var destinationEndpointInfo: EndpointInfo? {
		get {
			return MIDI.sharedInstance.destinationInfos.first(where: { $0.midiUniqueID == destinationEndpointUID })
		}
		set {
			destinationEndpointUID = newValue?.midiUniqueID
		}
	}
	
	var name: String {
		return customName ?? familyMember.name
	}
	
	
	// MARK: - METHODS
	// MARK: Type methods
	static func fetch(with uuid: UUID) throws -> Device? {
		guard let entityName = entity().name else {
			return nil
		}
		
		let deviceFetchRequest = NSFetchRequest<Device>(entityName: entityName)
		let deviceFetchPredicate = NSPredicate(format: "uuid == %@", uuid as CVarArg)
		deviceFetchRequest.predicate = deviceFetchPredicate
		
		return try PersistenceController.shared.container.viewContext.fetch(deviceFetchRequest).first
	}
	
	static func fetch(with deviceIdentity: Proteus.DeviceIdentity) -> Device? {
		guard let entityName = entity().name else {
			return nil
		}
		
		let devicesFetchRequest = NSFetchRequest<Device>(entityName: entityName)
		
		guard let allDevices = try? PersistenceController.shared.container.viewContext.fetch(devicesFetchRequest) else {
			return nil
		}
		
		let matchingDevices = allDevices.filter({
			guard $0.deviceID == deviceIdentity.deviceID,
				  $0.familyID == deviceIdentity.familyID,
				  $0.familyMember == deviceIdentity.familyMember else {
				return false
			}
			
			return true
		})
		
		return matchingDevices.first
	}
	
	// MARK: Initialisers
	convenience init(deviceIdentity: Proteus.DeviceIdentity, name: String?) {
		self.init(context: PersistenceController.shared.container.viewContext)
		
		uuid = UUID()
		deviceID = Int16(deviceIdentity.deviceID)
		familyID = Int32(deviceIdentity.familyID)
		familyMember = deviceIdentity.familyMember
		softwareVersion = deviceIdentity.softwareVersion
		customName = name
		
		sourceEndpointInfo = deviceIdentity.sourceEndpointInfo
		destinationEndpointInfo = deviceIdentity.destinationEndpointInfo
	}
}