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
					MIDIDeviceRow(device: device, selectedDevice: $selectedDevice)
				}
			}
		}
		.listStyle(InsetGroupedListStyle())
		.navigationBarTitle(context.navigationBarTitle)
	}
	
	// MARK: State properties
	@State var selectedDevice: MIDIDevice?
	
	
	// MARK: Stored properties
	let context: Context
}
