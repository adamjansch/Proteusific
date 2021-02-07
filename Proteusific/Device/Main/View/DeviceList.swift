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
			VStack(alignment: .center, spacing: 16.0, content: {
				if devices.isEmpty {
					let foregroundColor: UIColor = .systemGray
					
					Image(systemName: "pianokeys")
						.padding(EdgeInsets(top: 32.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
						.foregroundColor(Color(foregroundColor))
						.font(.system(size: 72.0))
					
					Text("You have no Devices!\nAdd a Device using the \"Add\" button above.")
						.multilineTextAlignment(.center)
						.padding(EdgeInsets(top: 0.0, leading: 32.0, bottom: 0.0, trailing: 32.0))
						.foregroundColor(Color(foregroundColor))
						.font(.system(size: 21.0))
					
					if UIDevice.current.userInterfaceIdiom == .pad {
						NavigationLink(destination: DeviceDetailView(), isActive: .constant(true)) {
							EmptyView()
						}
					}
				}
				
				List {
					ForEach(devices) { device in
						NavigationLink(destination: MultiDetailView(device: device)) {
							DeviceRow(device: device)
						}
						.isDetailLink(false)
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
