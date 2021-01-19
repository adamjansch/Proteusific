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
	private func send(sysExMessage: SysExMessage, responseAction: @escaping MIDIResponseAction) {
		let command = sysExMessage.requestCommand
		
		guard let commandMessage = MIDISysExMessage(bytes: command) else {
			responseAction(.failure(Error.sysExMessageCreationFailed(sysExMessage: sysExMessage)))
			return
		}
		
		pendingSysExMessages.append(sysExMessage)
		MIDI.sharedInstance.sendMessage(commandMessage.data)
		
		sleep(UInt32(Self.messageTimeoutDuration))
		
		switch pendingSysExMessages.firstIndex(of: sysExMessage) {
		case .some(let messageIndex):
			// We've waited for a response but not received one after the timeout duration.
			// Remove the sys ex message from the array and complete with error.
			pendingSysExMessages.remove(at: messageIndex)
			responseAction(.failure(Error.sysExMessageResponseTimedOut(sysExMessage: sysExMessage)))
			
		case .none:
			// If the request message is no longer in the array then
			// assume it was removed because a response was received.
			break
		}
	}
	
	func requestDeviceIdentity(endpointInfo: BiDirectionalEndpointInfo? = nil, responseAction: @escaping MIDIResponseAction) {
		/*
		WARNING! This method is designed to work synchronously. DO NOT CALL THIS FROM THE MAIN THREAD.
		(I would use Proteus.midiOperationQueue...)
		*/
		
		print("Attempting device identity retrieval...")
		
		// If endpoint info is provided then we need to override the current device
		// (very likely because we are trying to create a new device).
		if let endpointInfo = endpointInfo {
			let midi = MIDI.sharedInstance
			
			//  Close all inputs and outputs
			midi.closeAllInputsAndOutputs()
			
			// Open input and output based on provided endpoint infos
			let inMIDIUniqueID = endpointInfo.source?.midiUniqueID ?? 0
			midi.openInput(uid: inMIDIUniqueID)
			midi.openOutput(uid: endpointInfo.destination.midiUniqueID)
		}
		
		send(sysExMessage: .deviceIdentity(responseAction: responseAction), responseAction: responseAction)
	}
	
	func requestHardwareConfiguration(responseAction: @escaping MIDIResponseAction) {
		/*
		WARNING! This method is designed to work synchronously. DO NOT CALL THIS FROM THE MAIN THREAD.
		(I would use Proteus.midiOperationQueue...)
		*/
		
		print("Attempting hardware configuration retrieval...")
		
		send(sysExMessage: .hardwareConfiguration(responseAction: responseAction), responseAction: responseAction)
	}
	
	func requestGenericNames(for objectType: ObjectType, from rom: ROM, responseAction: @escaping MIDIResponseAction) {
		/*
		WARNING! This method is designed to work synchronously. DO NOT CALL THIS FROM THE MAIN THREAD.
		(I would use Proteus.midiOperationQueue...)
		*/
		
		print("Attempting generic names retrieval...")
		
		var nameCount: Int32
		switch objectType {
		case .preset:
			nameCount = rom.presetCount
		case .instrument:
			nameCount = rom.instrumentCount
		default:
			return
		}
		
		for nameIndex in 0..<nameCount {
			let sysExMessage = SysExMessage.genericName(type: objectType, objectID: MIDIWord(nameIndex), romID: MIDIWord(rom.id), responseAction: responseAction)
			send(sysExMessage: sysExMessage, responseAction: { result in
				print(result)
			})
			
			usleep(5000)
			//Proteus.midiOperationQueue.
		}
	}
	
	/*
	func retrievePresetDump(responseAction: @escaping MIDIResponseAction) {
		/*
		WARNING! This method is designed to work synchronously. DO NOT CALL THIS FROM THE MAIN THREAD.
		(I would use Proteus.midiOperationQueue...)
		*/
		
		print("Attempting device preset retrieval...")
		
		send(sysExMessage: .presetDumpClosedLoop(responseAction: responseAction), responseAction: responseAction)
	}
	*/
}
