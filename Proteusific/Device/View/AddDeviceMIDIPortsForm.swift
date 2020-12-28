//
//  AddDeviceMIDIPortsForm.swift
//  Proteusific
//
//  Created by Adam Jansch on 17/12/2020.
//

import SwiftUI
import AudioKit
import CoreMIDI

struct AddDeviceMIDIPortsForm: View {
	// MARK: - ENUMS
	// MARK: Data source enums
	private enum ListSection: Int, Identifiable, CaseIterable {
		case midiInPorts
		case midiOutPorts
		
		
		// MARK: - PROPERTIES
		// MARK: Identifiable properties
		var id: Int {
			return rawValue
		}
		
		// MARK: Computed properties
		var headerTitle: String {
			switch self {
			case .midiInPorts:
				return "MIDI In Port"
			case .midiOutPorts:
				return "MIDI Out Port"
			}
		}
		
		var endpointInfos: [EndpointInfo] {
			switch self {
			case .midiInPorts:
				return MIDI.sharedInstance.inputInfos
			case .midiOutPorts:
				return MIDI.sharedInstance.destinationInfos
			}
		}
	}
	
	
	// MARK: - PROPERTIES
	// MARK: Wrapper properties
	@State private var requestDeviceIdentityError: Proteus.Error?
	@State private var retrievedDeviceIdentity: Proteus.DeviceIdentity?
	@State private var selectedMIDIInEndpointInfo: EndpointInfo?
	@State private var selectedMIDIOutEndpointInfo: EndpointInfo?
	@State private var syncButtonDisabled = true
	
	@Binding var showAddDeviceForm: Bool
	
	// MARK: View properties
	var body: some View {
		NavigationView {
			VStack {
				let cancelButton = Button("Cancel", action: {
					showAddDeviceForm = false
				})
				
				let syncButton = Button("Sync", action: {
					syncButtonDisabled = true
					attemptSync()
				})
				.disabled(syncButtonDisabled)
				
				Form {
					ForEach(ListSection.allCases) { section in
						Section(header: Text(section.headerTitle)) {
							ForEach(section.endpointInfos) { endpointInfo in
								switch section {
								case .midiInPorts:
									AddDeviceMIDIPortsFormRow(endpointInfo: endpointInfo, selectedEndpointInfo: $selectedMIDIInEndpointInfo)
										.onChange(of: selectedMIDIInEndpointInfo, perform: { selectedEndpointInfo in
											guard selectedEndpointInfo == endpointInfo else {
												return
											}
											
											updateSyncButtonEnabledState()
										})
									
								case .midiOutPorts:
									AddDeviceMIDIPortsFormRow(endpointInfo: endpointInfo, selectedEndpointInfo: $selectedMIDIOutEndpointInfo)
										.onChange(of: selectedMIDIOutEndpointInfo, perform: { selectedEndpointInfo in
											guard selectedEndpointInfo == endpointInfo else {
												return
											}
											
											updateSyncButtonEnabledState()
										})
								}
							}
						}
					}
				}
				.padding(.top, 24.0)
				.navigationBarTitle("Add Device", displayMode: .inline)
				.navigationBarItems(leading: cancelButton, trailing: syncButton)
				.alert(item: $requestDeviceIdentityError) { error in
					Alert(title: Text("Synchronisation Error"), message: Text(error.alertMessage))
				}
				
				NavigationLink(
					destination: AddDeviceLinkDeviceForm(deviceIdentity: retrievedDeviceIdentity),
					isActive: .constant(retrievedDeviceIdentity != nil),
					label: {
						EmptyView()
					}
				)
				.onDisappear() {
					updateSyncButtonEnabledState()
				}
			}
		}
	}
	
	
	// MARK: - METHODS
	// MARK: UI methods
	private func updateSyncButtonEnabledState() {
		syncButtonDisabled = (selectedMIDIInEndpointInfo == nil) || (selectedMIDIOutEndpointInfo == nil)
	}
	
	// MARK: Utility methods
	private func attemptSync() {
		guard let selectedMIDIInEndpointInfo = selectedMIDIInEndpointInfo,
			  let selectedMIDIOutEndpointInfo = selectedMIDIOutEndpointInfo else {
			// The Sync button is disabled if either of these properties
			// is `nil`, so we shouldn't need any handling here.
			return
		}
		
		let combinedEndpointInfo = BiDirectionalEndpointInfo(in: selectedMIDIInEndpointInfo, out: selectedMIDIOutEndpointInfo)
		
		Proteus.shared.requestDeviceIdentity(endpointInfo: combinedEndpointInfo, responseAction: { result in
			let handleError: (Proteus.Error) -> Void = { error in
				print("Error Requesting Device Identity: \(error.debugMessage)")
				requestDeviceIdentityError = error
				updateSyncButtonEnabledState()
			}
			
			switch result {
			case .failure(let error):
				handleError(error)
				
			case .success(let midiResponse):
				print("MIDI response: \(midiResponse)")
				
				do {
					let deviceIdentity = try Proteus.DeviceIdentity(data: midiResponse)
					retrievedDeviceIdentity = deviceIdentity
					
				} catch {
					handleError(Proteus.Error.other(error: error))
				}
			}
		})
	}
}
