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
			return settings.midiInDevice?.displayName ?? settings.midiInDevice?.name ?? "None"
		case .midiOutDevice:
			return settings.midiOutDevice?.displayName ?? settings.midiOutDevice?.name ?? "None"
		}
	}
	
	// MARK: View properties
	var body: some View {
		NavigationLink(destination: MIDIDeviceSelectorList(setting: setting).environmentObject(settings)) {
			HStack {
				Text(setting.title)
				Spacer()
				Text(deviceName)
					.foregroundColor(.gray)
			}
		}
	}
}
