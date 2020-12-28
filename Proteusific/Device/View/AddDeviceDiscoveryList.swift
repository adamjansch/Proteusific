//
//  AddDeviceDiscoveryList.swift
//  Proteusific
//
//  Created by Adam Jansch on 27/12/2020.
//

import SwiftUI

struct AddDeviceDiscoveryList: View {
	// MARK: - PROPERTIES
	// MARK: Wrapper properties
	@ObservedObject var viewModel: AddDeviceDiscoveryListModel
	@State private var discoveryCompleted = false
	@State private var requestDeviceIdentityError: Proteus.Error?
	@Binding var showAddDeviceForm: Bool
	
	// MARK: View properties
	var body: some View {
		let cancelButton = Button("Cancel", action: {
			showAddDeviceForm = false
		})
		
		NavigationView {
			VStack {
				if let discoveredDeviceResults = viewModel.discoveredDeviceResults {
					// Filter out the `failure()` results
					let discoveredDevices = discoveredDeviceResults.compactMap({ try? $0.get() })
					
					switch discoveredDevices.isEmpty {
					case true:
						Text("No Proteus modules have been detected")
						Spacer()
						
					case false:
						List(discoveredDevices) { device in
							Text("Found \(device.softwareVersion) Proteus modules")
						}
						.listStyle(InsetGroupedListStyle())
					}
					
				} else {
					ProgressView()
				}
			}
			.navigationBarTitle("Add Device", displayMode: .automatic)
			.navigationBarItems(leading: cancelButton)
			.alert(item: $requestDeviceIdentityError) { error in
				Alert(title: Text("Discovery Error"), message: Text(error.alertMessage))
			}
		}
		.onAppear() {
			viewModel.beginDeviceDiscovery()
		}
	}
}
