//
//  MIDIDeviceSelector.swift
//  Proteusific
//
//  Created by Adam Jansch on 07/12/2020.
//

import SwiftUI

struct MIDIDeviceSelector: View {
	// MARK: - ENUMS
	// MARK: Context enum
	enum Context {
		case midiIn
		case midiOut
		
		var navigationBarTitle: String {
			switch self {
			case .midiIn:
				return "MIDI In Device"
			case .midiOut:
				return "MIDI Out Device"
			}
		}
	}
	
	
	// MARK: - PROPERTIES
	// MARK: View properties
	var body: some View {
		List {
			Section {
				ForEach(MIDIManager.shared.availableDevices) { device in
					let displayName = device.name ?? "<nil>"
					Text(displayName)
				}
			}
		}
		.listStyle(InsetGroupedListStyle())
		.navigationBarTitle(context.navigationBarTitle)
	}
	
	// MARK: Stored properties
	let context: Context
}
