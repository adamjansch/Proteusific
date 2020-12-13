//
//  MIDISettingsMIDIDeviceRow.swift
//  Proteusific
//
//  Created by Adam Jansch on 08/12/2020.
//

import SwiftUI

struct MIDISettingsMIDIDeviceRow: MIDISettingsRow {
	// MARK: - PROPERTIES
	// MARK: Wrapper properties
	@EnvironmentObject private var settings: Settings
	
	// MARK: Stored properties
	let setting: MIDISettingsList.Setting
	
	// MARK: Computed properties
	private var deviceName: String {
		switch setting {
		case .midiInDevice:
			return settings.midiInEndpointInfo?.displayName ?? "None"
		case .midiOutDevice:
			return settings.midiOutEndpointInfo?.displayName ?? "None"
		}
	}
	
	// MARK: View properties
	var body: some View {
		NavigationLink(destination: EndpointSelectorList(setting: setting).environmentObject(settings)) {
			HStack {
				Text(setting.title)
				Spacer()
				Text(deviceName)
					.foregroundColor(.gray)
			}
		}
	}
}
