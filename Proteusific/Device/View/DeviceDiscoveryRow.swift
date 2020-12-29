//
//  DeviceDiscoveryRow.swift
//  Proteusific
//
//  Created by Adam Jansch on 28/12/2020.
//

import SwiftUI

struct DeviceDiscoveryRow: View {
	// MARK: - PROPERTIES
	// MARK: Stored properties
	let device: Proteus.DeviceIdentity
	
	// MARK: Wrapper properties
	@Binding var selectedDevice: Proteus.DeviceIdentity?
	
	// MARK: View properties
	var body: some View {
		Button(action: {
			selectedDevice = device
			
		}, label: {
			HStack {
				let isSelected = (selectedDevice?.id == device.id)
				
				VStack(alignment: .leading, spacing: 8.0) {
					HStack(alignment: .bottom, spacing: 8.0) {
						Text(device.familyMember.name)
							.foregroundColor(Color(.label))
							.font(Font.title)
						
						Text("(v" + device.softwareVersion + ")")
							.foregroundColor(Color(.secondaryLabel))
							.font(Font.body.weight(.regular))
					}
					
					VStack(alignment: .leading) {
						if let sourceEndpointInfo = device.sourceEndpointInfo {
							Text("Source port: " + sourceEndpointInfo.displayName)
								.foregroundColor(Color(.secondaryLabel))
								.font(Font.body.weight(.regular))
						}
						
						Text("Destination port: " + device.destinationEndpointInfo.displayName)
							.foregroundColor(Color(.secondaryLabel))
							.font(Font.body.weight(.regular))
					}
				}
				.padding(EdgeInsets(top: 6.0, leading: 0.0, bottom: 8.0, trailing: 0.0))
				
				if isSelected {
					Spacer()
					Image(systemName: "checkmark")
						.foregroundColor(.blue)
				}
			}
		})
		
	}
}
