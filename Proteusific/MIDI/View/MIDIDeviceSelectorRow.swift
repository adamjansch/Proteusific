//
//  MIDIDeviceSelectorRow.swift
//  Proteusific
//
//  Created by Adam Jansch on 08/12/2020.
//

import SwiftUI

struct MIDIDeviceSelectorRow: View {
	// MARK: - PROPERTIES
	// MARK: Stored properties
	let device: MIDIDevice
	
	// MARK: Binding properties
	@Binding var selectedDevice: MIDIDevice?
	
	// MARK: View properties
	var body: some View {
		let isSelected = (selectedDevice == device)
		let displayName = device.name ?? "<nil>"
		
		HStack {
			Button(displayName, action: {
				selectedDevice = device
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
