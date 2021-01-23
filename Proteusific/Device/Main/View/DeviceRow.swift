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
		let rowBackground = (User.current?.currentDevice == device) ? Color(.systemBlue) : Color(.systemGray5)
		
		let sourcePortText = Text("Input:")
			.foregroundColor(Color(.secondaryLabel))
			.font(Font.body.weight(.regular))
		
		let destinationPortText = Text("Output:")
			.foregroundColor(Color(.secondaryLabel))
			.font(Font.body.weight(.regular))
		
		let notFoundText = Text("Not found")
			.foregroundColor(Color(.systemRed))
			.font(Font.body.weight(.regular))
		
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
					switch device.sourceEndpointInfo {
					case .some(let sourceEndpointInfo):
						HStack {
							sourcePortText
							Text(sourceEndpointInfo.displayName)
								.foregroundColor(Color(.secondaryLabel))
								.font(Font.body.weight(.regular))
						}
						
					case .none:
						HStack {
							sourcePortText
							notFoundText
						}
					}
					
					switch device.destinationEndpointInfo {
					case .some(let destinationEndpointInfo):
						HStack {
							destinationPortText
							Text(destinationEndpointInfo.displayName)
								.foregroundColor(Color(.secondaryLabel))
								.font(Font.body.weight(.regular))
						}
						
					case .none:
						HStack {
							destinationPortText
							notFoundText
						}
					}
				}
			}
			.padding(EdgeInsets(top: 6.0, leading: 0.0, bottom: 8.0, trailing: 0.0))
		}
		.listRowBackground(rowBackground)
	}
}
