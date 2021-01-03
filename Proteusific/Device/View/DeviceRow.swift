//
//  DeviceRow.swift
//  Proteusific
//
//  Created by Adam Jansch on 03/01/2021.
//

import SwiftUI

struct DeviceRow: View {
	// MARK: - PROPERTIES
	// MARK: Stored properties
	let device: Device
	
	// MARK: View properties
	var body: some View {
		let rowBackground = (Proteus.shared.currentDevice == device) ? Color(.systemBlue) : Color(.systemGray5)
		
		HStack {
			VStack(alignment: .leading, spacing: 8.0) {
				HStack(alignment: .bottom, spacing: 8.0) {
					Text(device.familyMember.name)
						.foregroundColor(Color(.label))
						.font(Font.title)
					
					if let softwareVersion = device.softwareVersion {
						Text("(v" + softwareVersion + ")")
							.foregroundColor(Color(.secondaryLabel))
							.font(Font.body.weight(.regular))
					}
				}
				
				VStack(alignment: .leading) {
					if let sourceEndpointInfo = device.sourceEndpointInfo {
						Text("Source port: " + sourceEndpointInfo.displayName)
							.foregroundColor(Color(.secondaryLabel))
							.font(Font.body.weight(.regular))
					}
					
					if let destinationEndpointInfo = device.sourceEndpointInfo {
						Text("Destination port: " + destinationEndpointInfo.displayName)
							.foregroundColor(Color(.secondaryLabel))
							.font(Font.body.weight(.regular))
					}
				}
			}
			.padding(EdgeInsets(top: 6.0, leading: 0.0, bottom: 8.0, trailing: 0.0))
		}
		.listRowBackground(rowBackground)
	}
}
