//
//  Proteus.swift
//  Proteusific
//
//  Created by Adam Jansch on 13/12/2020.
//

import AudioKit
import CoreMIDI

typealias BiDirectionalEndpointInfo = (source: EndpointInfo?, destination: EndpointInfo)

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
	private static let messageTimeoutDuration: TimeInterval = 1.0
	private static let midiOperationQueueLabel = "MIDIOperationQueue"
	static let midiOperationQueue = DispatchQueue(label: midiOperationQueueLabel, qos: .utility)
	
	// MARK: Stored properties
	var pendingSysExMessages: [SysExMessage] = []
	
	// MARK: Computed properties
	var currentDeviceID: MIDIByte {
		switch User.current?.currentDevice?.deviceID {
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
		/*
		WARNING! This method is designed to work synchronously. DO NOT CALL THIS FROM THE MAIN THREAD.
		(I would use Proteus.midiOperationQueue...)
		*/
		
		print("Attempting device info retrieval...")
		
		// If endpoint info is provided then we need to override the current device
		// (very likely because we are trying to create a new device).
		if let endpointInfo = endpointInfo {
			let midi = MIDI.sharedInstance
			
			//  Clear endpoints
			midi.clearEndpoints()
			
			// Open input and output based on provided endpoint infos
			let inMIDIUniqueID = endpointInfo.source?.midiUniqueID ?? 0
			midi.openInput(uid: inMIDIUniqueID)
			midi.openOutput(uid: endpointInfo.destination.midiUniqueID)
		}
		
		let deviceIdentityRequestMessage = SysExMessage.deviceIdentity(responseAction: responseAction)
		let deviceIdentityRequestCommand = deviceIdentityRequestMessage.requestCommand
		
		guard let deviceInquiryMessage = MIDISysExMessage(bytes: deviceIdentityRequestCommand) else {
			responseAction(.failure(Error.sysExMessageCreationFailed(sysExMessage: deviceIdentityRequestMessage)))
			return
		}
		
		pendingSysExMessages.append(deviceIdentityRequestMessage)
		MIDI.sharedInstance.sendMessage(deviceInquiryMessage.data)
		
		sleep(UInt32(Self.messageTimeoutDuration))
		
		switch pendingSysExMessages.firstIndex(of: deviceIdentityRequestMessage) {
		case .some(let requestMessageIndex):
			// We've waited for a response but not received one after the timeout duration.
			// Remove the sys ex message from the array and complete with error.
			pendingSysExMessages.remove(at: requestMessageIndex)
			responseAction(.failure(Error.sysExMessageResponseTimedOut(sysExMessage: deviceIdentityRequestMessage)))
			
		case .none:
			// If the request message is no longer in the array then
			// assume it was removed because a response was received.
			break
		}
	}
	
	func retrievePatches(responseAction: @escaping MIDIResponseAction) {
		/*
		WARNING! This method is designed to work synchronously. DO NOT CALL THIS FROM THE MAIN THREAD.
		(I would use Proteus.midiOperationQueue...)
		*/
		
		print("Attempting device patch retrieval...")
		
		let presetDumpClosedLoopRequestMessage = SysExMessage.presetDumpClosedLoop(responseAction: responseAction)
		let presetDumpClosedLoopRequestCommand = presetDumpClosedLoopRequestMessage.requestCommand
		
		guard let presetDumpClosedLoopMessage = MIDISysExMessage(bytes: presetDumpClosedLoopRequestCommand) else {
			responseAction(.failure(Error.sysExMessageCreationFailed(sysExMessage: presetDumpClosedLoopRequestMessage)))
			return
		}
		
		pendingSysExMessages.append(presetDumpClosedLoopRequestMessage)
		MIDI.sharedInstance.sendMessage(presetDumpClosedLoopMessage.data)
		
		sleep(UInt32(Self.messageTimeoutDuration))
		
		switch pendingSysExMessages.firstIndex(of: presetDumpClosedLoopRequestMessage) {
		case .some(let requestMessageIndex):
			// We've waited for a response but not received one after the timeout duration.
			// Remove the sys ex message from the array and complete with error.
			pendingSysExMessages.remove(at: requestMessageIndex)
			responseAction(.failure(Error.sysExMessageResponseTimedOut(sysExMessage: presetDumpClosedLoopRequestMessage)))
			
		case .none:
			// If the request message is no longer in the array then
			// assume it was removed because a response was received.
			break
		}
	}
}
