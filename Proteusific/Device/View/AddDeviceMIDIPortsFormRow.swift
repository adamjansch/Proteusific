//
//  AddDeviceMIDIPortsFormRow.swift
//  Proteusific
//
//  Created by Adam Jansch on 18/12/2020.
//

import SwiftUI
import AudioKit

struct AddDeviceMIDIPortsFormRow: View {
	// MARK: - PROPERTIES
	// MARK: Stored properties
	let endpointInfo: EndpointInfo
	
	// MARK: Wrapper properties
	@Binding var selectedEndpointInfo: EndpointInfo?
	
	// MARK: View properties
	var body: some View {
		HStack {
			Button(endpointInfo.displayName, action: {
				selectedEndpointInfo = endpointInfo
			})
			.font(Font.body.weight(.regular))
			.foregroundColor(Color(UIColor.label))
			
			let isSelected = (selectedEndpointInfo == endpointInfo)
			
			if isSelected {
				Spacer()
				Image(systemName: "checkmark")
					.foregroundColor(.blue)
			}
		}
	}
}
