//
//  EndpointSelectorRow.swift
//  Proteusific
//
//  Created by Adam Jansch on 08/12/2020.
//

import SwiftUI
import AudioKit

struct EndpointSelectorRow: View {
	// MARK: - PROPERTIES
	// MARK: Wrapper properties
	@EnvironmentObject private var settings: Settings
	
	// MARK: Stored properties
	let setting: MIDISettingsList.Setting
	let endpointInfo: EndpointInfo
	
	// MARK: Computed properties
	private var selectedEndpointInfo: EndpointInfo? {
		switch setting {
		case .midiInConnection:
			return settings.midiInEndpointInfo
		case .midiOutConnection:
			return settings.midiOutEndpointInfo
		}
	}
	
	// MARK: View properties
	var body: some View {
		let isSelected = (selectedEndpointInfo == endpointInfo)
		let nameComponents = [endpointInfo.manufacturer, endpointInfo.displayName].filter({ $0.isEmpty == false })
		let displayName = nameComponents.joined(separator: " ")
		
		HStack {
			Button(displayName, action: {
				switch setting {
				case .midiInConnection:
					settings.midiInEndpointInfo = endpointInfo
				case .midiOutConnection:
					settings.midiOutEndpointInfo = endpointInfo
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
