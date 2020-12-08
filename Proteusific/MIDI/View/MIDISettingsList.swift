//
//  MIDISettingsList.swift
//  Proteusific
//
//  Created by Adam Jansch on 08/12/2020.
//

import SwiftUI

struct MIDISettingsList: View {
	// MARK: - ENUMS
	// MARK: Data source enums
	private enum SettingsGroup: Int, Identifiable, CaseIterable {
		case midiDevices
		
		
		// MARK: - PROPERTIES
		// MARK: Identifiable properties
		var id: Int {
			return rawValue
		}
		
		// MARK: Computed properties
		var settings: [MIDISettingsRow.Setting] {
			switch self {
			case .midiDevices:
				return [.midiInDevice, .midiOutDevice]
			}
		}
		
		var headerTitle: String {
			switch self {
			case .midiDevices:
				return "MIDI Devices"
			}
		}
	}
	
	
	// MARK: - PROPERTIES
	// MARK: View properties
	var body: some View {
		NavigationView {
			List {
				ForEach(SettingsGroup.allCases) { section in
					Section(header: Text(section.headerTitle)) {
						ForEach(section.settings) { setting in
							MIDISettingsRow(setting: setting)
						}
					}
				}
			}
			.listStyle(InsetGroupedListStyle())
			.navigationBarTitle("MIDI Settings")
		}
	}
}
