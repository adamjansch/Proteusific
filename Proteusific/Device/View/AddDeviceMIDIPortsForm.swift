//
//  AddDeviceMIDIPortsForm.swift
//  Proteusific
//
//  Created by Adam Jansch on 17/12/2020.
//

import SwiftUI
import AudioKit

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
	@State private var selectedMIDIInEndpointInfo: EndpointInfo?
	@State private var selectedMIDIOutEndpointInfo: EndpointInfo?
	@State private var syncButtonDisabled: Bool = true
	
	@Binding var showAddDeviceForm: Bool
	
	// MARK: View properties
	var body: some View {
		NavigationView {
			let cancelButton = Button("Cancel", action: {
				showAddDeviceForm = false
			})
			
			let syncButton = Button("Sync", action: {
				print("Attempt sync")
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
		}
	}
	
	
	// MARK: - METHODS
	// MARK: Utility methods
	private func updateSyncButtonEnabledState() {
		syncButtonDisabled = (selectedMIDIInEndpointInfo == nil) || (selectedMIDIOutEndpointInfo == nil)
	}
}
