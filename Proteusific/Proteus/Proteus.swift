//
//  Proteus.swift
//  Proteusific
//
//  Created by Adam Jansch on 13/12/2020.
//

import AudioKit
import CoreMIDI

typealias BiDirectionalEndpointInfo = (in: EndpointInfo?, out: EndpointInfo)

final class Proteus {
	// MARK: - ENUMS
	// MARK: Error enum
	enum Error: Swift.Error, Identifiable {
		case incompatibleSysExMessage(data: [MIDIByte])
		case other(error: Swift.Error)
		case selfNil
		case sysExMessageCreationFailed(sysExMessage: SysExMessage)
		case sysExMessageResponseTimedOut(sysExMessage: SysExMessage)
		
		// MARK: - PROPERTIES
		// MARK: Identifiable properties
		var id: String {
			switch self {
			case .incompatibleSysExMessage:
				return "Incompatible SysEx Message"
			case .other:
				return "Other"
			case .selfNil:
				return "Self Nil"
			case .sysExMessageCreationFailed:
				return "SysEx Message Creation Failed"
			case .sysExMessageResponseTimedOut:
				return "SysEx Message Response Timed Out"
			}
		}
		
		// MARK: Computed properties
		var debugMessage: String {
			switch self {
			case .incompatibleSysExMessage(let data):
				return "Incompatible SysEx message received: \(data)"
			case .other(let error):
				return "Other error encountered: \(error.localizedDescription)"
			case .selfNil:
				return "Self Nil"
			case .sysExMessageCreationFailed(let sysExMessage):
				return "SysEx message creation failed: \(sysExMessage)"
			case .sysExMessageResponseTimedOut(let sysExMessage):
				return "SysEx message response timed out: \(sysExMessage)"
			}
		}
		
		var alertMessage: String {
			switch self {
			case .incompatibleSysExMessage:
				return "Incompatible System Exclusive message received."
			case .sysExMessageCreationFailed:
				return "System Exclusive message creation failed."
			case .sysExMessageResponseTimedOut:
				return "System Exclusive message response timed out."
			default:
				return "General error encountered."
			}
		}
	}
	
	
	// MARK: - PROPERTIES
	// MARK: Shared instance
	static let shared = Proteus()
	
	// MARK: Type properties
	private static let midiOperationQueueLabel = "MIDIOperationQueue"
	private static let midiOperationQueue = DispatchQueue(label: midiOperationQueueLabel, qos: .userInitiated)
	private static let messageTimeoutDuration: TimeInterval = 1.0
	
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
	
	// MARK: Device methods
	func requestDeviceIdentity(endpointInfo: BiDirectionalEndpointInfo? = nil, responseAction: @escaping MIDIResponseAction) {
		print("Attempting device info retrieval...")
		
		// If endpoint info is provided then we need to override the current device
		// (very likely because we are trying to create a new device).
		if let endpointInfo = endpointInfo {
			let midi = MIDI.sharedInstance
			
			//  Close current input and output
			midi.closeInput()
			midi.closeOutput()
			
			// Open input and output based on provided endpoint infos
			let inMIDIUniqueID = endpointInfo.in?.midiUniqueID ?? 0
			midi.openInput(uid: inMIDIUniqueID)
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
			
			Self.midiOperationQueue.asyncAfter(deadline: .now() + Self.messageTimeoutDuration, execute: {
				switch strongSelf.pendingSysExMessages.firstIndex(of: deviceIdentityRequestMessage) {
				case .some(let requestMessageIndex):
					// We've waited for a response but not received one after the timeout duration.
					// Remove the sys ex message from the array and complete with error.
					strongSelf.pendingSysExMessages.remove(at: requestMessageIndex)
					responseAction(.failure(Error.sysExMessageResponseTimedOut(sysExMessage: deviceIdentityRequestMessage)))
					
				case .none:
					// If the request message is no longer in the array then
					// assume it was removed because a response was received.
					break
				}
			})
		}
	}
}
