//
//  Part+CoreDataClass.swift
//  Proteusific
//
//  Created by Adam Jansch on 12/02/2021.
//
//

import CoreData

public class Part: NSManagedObject {
	// MARK: - PROPERTIES
	// MARK: Computed properties
	var preset: Preset? {
		return try? Preset.fetch(with: presetID)
	}
	
	var rom: ROM? {
		return try? ROM.fetch(with: romID)
	}
	
	
	// MARK: - METHODS
	// MARK: Initializers
	convenience init(channelParameters: Proteus.CurrentSetupDump.ChannelParameters, index: Int16) throws {
		self.init(context: PersistenceController.shared.container.viewContext)
		
		self.index = index
		self.presetID = Int16(channelParameters.presetID)
		self.romID = Int16(channelParameters.romID)
		
		self.volume = Int16(channelParameters.volume)
		self.pan = Int16(channelParameters.pan)
		self.mixOutput = Int16(channelParameters.mixOutput)
		
		self.channelEnable = channelParameters.channelEnable
		self.receiveProgramChange = channelParameters.receiveProgramChange
	}
}
