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
		var settings: [Setting] {
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
	
	enum Setting: Int, Identifiable {
		case midiInDevice
		case midiOutDevice
		
		
		// MARK: - PROPERTIES
		// MARK: Identifiable properties
		var id: Int {
			return rawValue
		}
		
		// MARK: Computed properties
		var navigationBarTitle: String {
			switch self {
			case .midiInDevice:
				return "MIDI In Device"
			case .midiOutDevice:
				return "MIDI Out Device"
			}
		}
		
		var title: String {
			switch self {
			case .midiInDevice:
				return "MIDI In"
			case .midiOutDevice:
				return "MIDI Out"
			}
		}
	}
	
	
	// MARK: - PROPERTIES
	// MARK: Stored properties
	private var settings = Settings.current
	
	// MARK: View properties
	var body: some View {
		NavigationView {
			List {
				ForEach(SettingsGroup.allCases) { section in
					Section(header: Text(section.headerTitle)) {
						ForEach(section.settings) { setting in
							MIDISettingsMIDIDeviceRow(setting: setting)
								.environmentObject(settings)
						}
					}
				}
			}
			.listStyle(InsetGroupedListStyle())
			.navigationBarTitle("MIDI Settings")
		}
	}
}
