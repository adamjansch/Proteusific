//
//  MIDIDeviceSelectorRow.swift
//  Proteusific
//
//  Created by Adam Jansch on 08/12/2020.
//

import SwiftUI

struct MIDIDeviceSelectorRow: View {
	// MARK: - PROPERTIES
	// MARK: Wrapper properties
	@EnvironmentObject private var settings: Settings
	
	// MARK: Stored properties
	let setting: MIDISettingsList.Setting
	let device: MIDIDevice
	
	// MARK: Computed properties
	private var selectedDevice: MIDIDevice? {
		switch setting {
		case .midiInDevice:
			return settings.midiInDevice
		case .midiOutDevice:
			return settings.midiOutDevice
		}
	}
	
	// MARK: View properties
	var body: some View {
		let isSelected = (selectedDevice == device)
		let displayName = device.displayName ?? device.name ?? "<nil>"
		
		HStack {
			Button(displayName, action: {
				let deviceUniqueID: NSNumber?
				switch device.uniqueID {
				case .some(let uniqueID):
					deviceUniqueID = NSNumber(value: uniqueID)
				default:
					deviceUniqueID = nil
				}
				
				switch setting {
				case .midiInDevice:
					settings.midiInDeviceID = deviceUniqueID
				case .midiOutDevice:
					settings.midiOutDeviceID = deviceUniqueID
				}
				
				PersistenceController.shared.container.saveContext()
			})
			.foregroundColor(Color(UIColor.label))
			
			if isSelected {
				Spacer()
				Image(systemName: "checkmark")
					.foregroundColor(.blue)
			}
		}
	}
}
