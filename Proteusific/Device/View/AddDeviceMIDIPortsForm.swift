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
		
		let combinedEndpointInfo = BiEndpointInfo(in: selectedMIDIInEndpointInfo, out: selectedMIDIOutEndpointInfo)
		MIDI.sharedInstance.addListener(self)
		
		Proteus.shared.requestDeviceIdentity(endpointInfo: combinedEndpointInfo, completion: { result in
			switch result {
			case .failure(let error):
				print("Error requesting device identity: \(error)")
				updateSyncButtonEnabledState()
				
			case .success:
				break
			}
		})
	}
}


// MARK: - PROTOCOL CONFORMANCE
extension AddDeviceMIDIPortsForm: MIDIListener {
	// MARK: MIDIListener
	func receivedMIDISystemCommand(_ data: [MIDIByte], portID: MIDIUniqueID?, offset: MIDITimeStamp) {
		//MIDI.sharedInstance.removeListener(self)
		
		//print(data)
	}
	
	func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
		print("AddDeviceMIDIPortsForm doesn't respond to MIDI Note On")
	}
	
	func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
		print("AddDeviceMIDIPortsForm doesn't respond to MIDI Note Off")
	}
	
	func receivedMIDIController(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
		print("AddDeviceMIDIPortsForm doesn't respond to MIDI CC")
	}
	
	func receivedMIDIAftertouch(noteNumber: MIDINoteNumber, pressure: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
		print("AddDeviceMIDIPortsForm doesn't respond to MIDI Aftertouch")
	}
	
	func receivedMIDIAftertouch(_ pressure: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
		print("AddDeviceMIDIPortsForm doesn't respond to MIDI Aftertouch")
	}
	
	func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
		print("AddDeviceMIDIPortsForm doesn't respond to MIDI Pitch Wheel")
	}
	
	func receivedMIDIProgramChange(_ program: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
		print("AddDeviceMIDIPortsForm doesn't respond to MIDI Program Change")
	}
	
	func receivedMIDISetupChange() {
		print("AddDeviceMIDIPortsForm doesn't respond to MIDI Setup Change")
	}
	
	func receivedMIDIPropertyChange(propertyChangeInfo: MIDIObjectPropertyChangeNotification) {
		print("AddDeviceMIDIPortsForm doesn't respond to MIDI Property Change")
	}
	
	func receivedMIDINotification(notification: MIDINotification) {
		print("AddDeviceMIDIPortsForm doesn't respond to MIDI Notification")
	}
}
