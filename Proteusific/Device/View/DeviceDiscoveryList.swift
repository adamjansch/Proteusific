//
//  DeviceDiscoveryList.swift
//  Proteusific
//
//  Created by Adam Jansch on 27/12/2020.
//

import SwiftUI
import AudioKit

struct DeviceDiscoveryList: View {
	// MARK: - ENUMS
	// MARK: Data source enums
	private enum ListSection: Int, Identifiable, CaseIterable {
		case discoveredDevices
		
		// MARK: - PROPERTIES
		// MARK: Identifiable properties
		var id: Int {
			return rawValue
		}
		
		// MARK: Computed properties
		var headerTitle: String {
			switch self {
			case .discoveredDevices:
				return "Discovered Devices"
			}
		}
	}
	
	
	// MARK: - PROPERTIES
	// MARK: Wrapper properties
	@Environment(\.managedObjectContext) private var viewContext
	@ObservedObject var viewModel: DeviceDiscoveryListModel
	@Binding var showAddDeviceForm: Bool
	
	@State private var selectedDevice: Proteus.DeviceIdentity?
	@State private var requestDeviceIdentityError: Proteus.Error?
	@State private var addButtonDisabled = true
	
	// MARK: View properties
	var body: some View {
		let cancelButton = Button("Cancel", action: {
			showAddDeviceForm = false
		})
		
		let addButton = Button("Add", action: {
			addSelectedDevice()
		})
		.disabled(addButtonDisabled)
		
		NavigationView {
			VStack {
				// Filter out the `failure()` results
				let discoveredDevices = viewModel.discoveredDeviceResults.compactMap({ try? $0.get() })
				
				switch (viewModel.discoveryCompleted, discoveredDevices.isEmpty) {
				case (false, _):
					Text("Discovering Proteus devices...")
						.padding(24.0)
					
					SegmentedActivityIndicator(completedSegmentCount: viewModel.discoveredDeviceResults.count, maxSegmentCount: MIDI.sharedInstance.destinationInfos.count)
						.frame(width: SegmentedActivityIndicator.defaultWidth, height: SegmentedActivityIndicator.defaultWidth, alignment: .center)
					
				case (true, true):
					Text("No Proteus devices have been detected")
						.padding(24.0)
					
					Spacer()
					
				case (true, false):
					List {
						ForEach(ListSection.allCases) { section in
							Section(header: Text(section.headerTitle)) {
								ForEach(discoveredDevices) { device in
									DeviceDiscoveryRow(device: device, selectedDevice: $selectedDevice)
										.onChange(of: selectedDevice, perform: { device in
											guard selectedDevice == device else {
												return
											}
											
											addButtonDisabled = false
										})
								}
							}
						}
					}
					.listStyle(InsetGroupedListStyle())
					.padding(EdgeInsets(top: 24.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
				}
			}
			.navigationBarTitle("Add Device", displayMode: .inline)
			.navigationBarItems(leading: cancelButton, trailing: addButton)
			.alert(item: $requestDeviceIdentityError) { error in
				Alert(title: Text("Discovery Error"), message: Text(error.alertMessage))
			}
		}
		.onAppear() {
			viewModel.beginDeviceDiscovery()
		}
	}
	
	
	// MARK: - METHODS
	// MARK: Add methods
	private func addSelectedDevice() {
		guard let selectedDevice = selectedDevice else {
			print("Couldn't Add Devce: `selectedDevice` is `nil`")
			return
		}
		
		let newDevice = Device(deviceIdentity: selectedDevice, name: "")
		Proteus.shared.currentDevice = newDevice
		
		do {
			try viewContext.save()
			showAddDeviceForm = false
			
		} catch {
			requestDeviceIdentityError = .other(error: error)
		}
	}
	
	// MARK: Utility methods
	private func segmentDegrees(for index: Int) -> (start: Double, end: Double) {
		let segmentDegrees = 360 / MIDI.sharedInstance.destinationInfos.count
		let startDegree = ((segmentDegrees * index) + 270) % 360
		let endDegree = ((segmentDegrees * (index + 1)) + 270) % 360
		return (start: Double(startDegree), end: Double(endDegree))
	}
}
