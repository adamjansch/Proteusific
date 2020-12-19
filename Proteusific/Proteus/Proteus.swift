//
//  Proteus.swift
//  Proteusific
//
//  Created by Adam Jansch on 13/12/2020.
//

import Foundation
import AudioKit
import CoreMIDI

typealias BiEndpointInfo = (in: EndpointInfo, out: EndpointInfo)

final class Proteus {
	// MARK: - ENUMS
	// MARK: Error enum
	enum Error: Swift.Error {
		case incompatibleSysExMessage(data: [MIDIByte])
		case selfNil
		case sysExMessageCreationFailed(sysExMessage: SysExMessage)
	}
	
	
	// MARK: - PROPERTIES
	// MARK: Shared instance
	static let shared = Proteus()
	
	// MARK: Type properties
	private static var midiOperationQueueLabel = "MIDIOperationQueue"
	private static var midiOperationQueue = DispatchQueue(label: midiOperationQueueLabel, qos: .userInitiated)
	
	// MARK: Stored properties
	var pendingSysExMessages: [SysExMessage] = []
	
	var currentDevice: Device? {
		didSet {
			let midi = MIDI.sharedInstance
			
			switch currentDevice {
			case .some(let device):
				if let inEndpointUID = device.inEndpointUID,
				   midi.inputInfos.contains(where: { inEndpointUID == $0.midiUniqueID }) {
					midi.openInput(uid: inEndpointUID)
					
				} else {
					midi.closeInput()
				}
				
				if let outEndpointUID = device.outEndpointUID,
				   midi.destinationInfos.contains(where: { outEndpointUID == $0.midiUniqueID }) {
					midi.openOutput(uid: outEndpointUID)
					
				} else {
					midi.closeOutput()
				}
				
			case .none:
				midi.closeInput()
				midi.closeOutput()
			}
		}
	}
	
	// MARK: Computed properties
	var currentDeviceID: MIDIByte {
		switch currentDevice?.deviceID {
		case .some(let deviceID):
			return MIDIByte(deviceID)
			
		case .none:
			return SysExMessage.allBroadcastID
		}
	}
	
	
	// MARK: - METHODS
	// MARK: Initializers
	private init() {}
	
	deinit {
		MIDI.sharedInstance.removeListener(self)
	}
	
	// MARK: Configuration method
	func configure() {
		MIDI.sharedInstance.clearListeners()
		MIDI.sharedInstance.addListener(self)
	}
	
	// MARK: MIDI methods
	func requestDeviceIdentity(endpointInfo: BiEndpointInfo? = nil, responseAction: @escaping MIDIResponseAction) {
		print("Attempting device info retrieval...")
		
		// If endpoint info is provided then we need to override the current device
		// (very likely because we are trying to create a new device).
		if let endpointInfo = endpointInfo {
			let midi = MIDI.sharedInstance
			
			//  Close current input and output
			midi.closeInput()
			midi.closeOutput()
			
			// Open input and output based on provided endpoint infos
			midi.openInput(uid: endpointInfo.in.midiUniqueID)
			midi.openOutput(uid: endpointInfo.out.midiUniqueID)
		}
		
		Self.midiOperationQueue.async { [weak self] in
			guard let strongSelf = self else {
				responseAction(.failure(Error.selfNil))
				return
			}
			
			let deviceIdentityRequestMessage = SysExMessage.deviceIdentity(responseAction: responseAction)
			let deviceIdentityRequestCommand = deviceIdentityRequestMessage.requestCommand
			
			guard let deviceInquiryMessage = MIDISysExMessage(bytes: deviceIdentityRequestCommand) else {
				responseAction(.failure(Error.sysExMessageCreationFailed(sysExMessage: deviceIdentityRequestMessage)))
				return
			}
			
			strongSelf.pendingSysExMessages.append(deviceIdentityRequestMessage)
			MIDI.sharedInstance.sendMessage(deviceInquiryMessage.data)
		}
	}
	
	func handleDeviceIdentity(data: [MIDIByte]) throws {
		let deviceIdentity = try DeviceIdentity(data: data)
		
//		switch Device.fetch(with: deviceIdentity) {
//		case .some(let matchingDevice):
//			
//			
//		case .none:
//			let device = Device(deviceIdentity: deviceIdentity, name: nil)
//		}
	}
}
