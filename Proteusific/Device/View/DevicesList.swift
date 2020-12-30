//
//  DevicesList.swift
//  Proteusific
//
//  Created by Adam Jansch on 17/12/2020.
//

import SwiftUI

struct DevicesList: View {
	// MARK: - PROPERTIES
	// MARK: Wrapper properties
	@FetchRequest(
		sortDescriptors: [],
		animation: .default)
	private var devices: FetchedResults<Device>
	
	@State private var showAddDeviceForm = false
	
	// MARK: View properties
	var body: some View {
		NavigationView {
			VStack(alignment: .center, spacing: 4.0, content: {
				if devices.isEmpty {
					Text("You have no Devices!\nAdd a Device using the \"Add\" button above.")
						.multilineTextAlignment(.center)
						.padding(32.0)
				}
				
				List {
					ForEach(devices) { device in
						Text("Device: \(device.deviceID)")
					}
				}
				.listStyle(InsetGroupedListStyle())
				.navigationBarTitle("Devices", displayMode: .inline)
				.navigationBarItems(
					trailing:
						Button("Add", action: {
							showAddDeviceForm = true
						})
						.sheet(isPresented: $showAddDeviceForm, content: {
							let viewModel = DeviceDiscoveryListModel()
							DeviceDiscoveryList(viewModel: viewModel, showAddDeviceForm: $showAddDeviceForm)
						})
				)
				
				HStack {
					Button("App Info", action: {
						print("Open Infos")
					})
					Spacer()
				}
				.padding(16.0)
			})
			.background(Color(.systemGroupedBackground))
		}
	}
}
