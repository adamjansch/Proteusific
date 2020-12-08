//
//  MIDISettingsRow.swift
//  Proteusific
//
//  Created by Adam Jansch on 08/12/2020.
//

import SwiftUI

struct MIDISettingsRow: View {
	// MARK: - ENUMS
	// MARK: Data source enums
	enum Setting: Int, Identifiable {
		case midiInDevice
		case midiOutDevice
		
		
		// MARK: - PROPERTIES
		// MARK: Identifiable properties
		var id: Int {
			return rawValue
		}
		
		// MARK: Computed properties
		var title: String {
			switch self {
			case .midiInDevice:
				return "MIDI In"
			case .midiOutDevice:
				return "MIDI Out"
			}
		}
		
		var context: MIDIDeviceSelectorList.Context {
			switch self {
			case .midiInDevice:
				return .midiIn
			case .midiOutDevice:
				return .midiOut
			}
		}
	}
	
	
	// MARK: - PROPERTIES
	// MARK: View properties
	var body: some View {
		NavigationLink(destination: MIDIDeviceSelectorList(context: setting.context)) {
			HStack {
				Text(setting.title)
				Spacer()
				Text("None")
					.foregroundColor(.gray)
			}
		}
	}
	
	// MARK: Stored properties
	let setting: Setting
}
