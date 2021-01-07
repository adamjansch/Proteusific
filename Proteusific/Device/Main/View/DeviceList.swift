//
//  DeviceList.swift
//  Proteusific
//
//  Created by Adam Jansch on 17/12/2020.
//

import SwiftUI

struct DeviceList: View {
	// MARK: - PROPERTIES
	// MARK: Wrapper properties
	@FetchRequest(
		sortDescriptors: [],
		animation: .default)
	private var devices: FetchedResults<Device>
	
	@State private var showAddDeviceList = false
	@State private var showAppInfoList = false
	
	// MARK: View properties
	var body: some View {
		NavigationView {
			VStack(alignment: .center, spacing: 4.0, content: {
				if devices.isEmpty {
					Text("You have no Devices!\nAdd a Device using the \"Add\" button above.")
						.multilineTextAlignment(.center)
						.padding(32.0)
					
					NavigationLink(destination: DeviceDetailView(), isActive: .constant(true)) {
						EmptyView()
					}
				}
				
				List {
					ForEach(devices) { device in
						NavigationLink(destination: DeviceDetailView()) {
							DeviceRow(device: device)
						}
						.onTapGesture {
							User.current?.currentDevice = device
						}
					}
				}
				.listStyle(InsetGroupedListStyle())
				.navigationBarTitle("Devices", displayMode: .inline)
				.navigationBarItems(trailing:
					Button("Add", action: {
						showAddDeviceList = true
					})
					.sheet(isPresented: $showAddDeviceList, content: {
						let viewModel = DeviceDiscoveryListModel()
						DeviceDiscoveryList(viewModel: viewModel, showAddDeviceList: $showAddDeviceList)
					})
				)
				
				HStack {
					Button(action: {
						showAppInfoList = true
					}, label: {
						Image(systemName: "info.circle.fill")
							.font(.system(size: 24.0))
					})
					.sheet(isPresented: $showAppInfoList, content: {
						AppInfoList(showAppInfoList: $showAppInfoList)
					})
					
					Spacer()
				}
				.padding(16.0)
			})
			.background(Color(.systemGroupedBackground))
			.edgesIgnoringSafeArea(.bottom)
		}
	}
}
