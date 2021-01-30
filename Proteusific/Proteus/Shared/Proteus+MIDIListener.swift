//
//  Proteus+MIDIListener.swift
//  Proteusific
//
//  Created by Adam Jansch on 16/12/2020.
//

import AudioKit
import CoreMIDI

extension Proteus: MIDIListener {
	func receivedMIDISystemCommand(_ data: [MIDIByte], portID: MIDIUniqueID?, offset: MIDITimeStamp) {
		if let currentDevice = User.current?.currentDevice,
		   currentDevice.sourceEndpointUID != portID {
			return
		}
		
		guard let pendingSysExMessage = pendingSysExMessages.first(where: { $0.matches(data: data) }) else {
			return
		}
		
		switch pendingSysExMessage {
		case .deviceIdentity(let endpointInfos, _):
			pendingSysExMessage.responseAction(.success((data, endpointInfos)))
			
		default:
			pendingSysExMessage.responseAction(.success((data, nil)))
		}
		
		pendingSysExMessages.removeAll(where: { $0 == pendingSysExMessage })
		clearSysExResponseTimer()
		
		Proteus.midiOperationQueue.asyncAfter(deadline: .now() + 0.02, execute: { [weak self] in
			self?.servicePendingSysExMessages(responseAction: nil)
		})
	}
	
	func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
		// Not used
		print("receivedMIDINoteOn - noteNumber: \(noteNumber); velocity: \(velocity); channel: \(channel); portID: \(String(describing: portID)); offset: \(offset)")
	}
	
	func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
		// Not used
		print("receivedMIDINoteOff - noteNumber: \(noteNumber); velocity: \(velocity); channel: \(channel); portID: \(String(describing: portID)); offset: \(offset)")
	}
	
	func receivedMIDIController(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
		// Not used
		print("receivedMIDIController - controller: \(controller); value: \(value); channel: \(channel); portID: \(String(describing: portID)); offset: \(offset)")
	}
	
	func receivedMIDIAftertouch(noteNumber: MIDINoteNumber, pressure: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
		// Not used
		print("receivedMIDIAftertouch - noteNumber: \(noteNumber); pressure: \(pressure); channel: \(channel); portID: \(String(describing: portID)); offset: \(offset)")
	}
	
	func receivedMIDIAftertouch(_ pressure: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
		// Not used
		print("receivedMIDIAftertouch - pressure: \(pressure); channel: \(channel); portID: \(String(describing: portID)); offset: \(offset)")
	}
	
	func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
		// Not used
		print("receivedMIDIPitchWheel - pitchWheelValue: \(pitchWheelValue); channel: \(channel); portID: \(String(describing: portID)); offset: \(offset)")
	}
	
	func receivedMIDIProgramChange(_ program: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
		print("receivedMIDIProgramChange - program: \(program); channel: \(channel); portID: \(String(describing: portID)); offset: \(offset)")
	}
	
	func receivedMIDISetupChange() {
		// Not used
		print("receivedMIDISetupChange")
	}
	
	func receivedMIDIPropertyChange(propertyChangeInfo: MIDIObjectPropertyChangeNotification) {
		// Not used
		print("receivedMIDIPropertyChange - propertyChangeInfo: \(propertyChangeInfo)")
	}
	
	func receivedMIDINotification(notification: MIDINotification) {
		// Not used
		print("receivedMIDINotification - notification: \(notification)")
	}
}
