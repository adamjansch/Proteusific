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
	// MARK: - PROPERTIES
	// MARK: Shared instance
	static let shared = Proteus()
	
	// MARK: Type properties
	private static let messageTimeoutDuration: TimeInterval = 1.0
	private static let midiOperationQueueLabel = "MIDIOperationQueue"
	static let midiOperationQueue = DispatchQueue(label: midiOperationQueueLabel, qos: .utility)
	
	// MARK: Stored properties
	var pendingSysExMessages: [SysExMessage] = []
	var sysExResponseTimer: Timer?
	
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
		clearSysExResponseTimer()
	}
	
	// MARK: Configuration method
	func configure() {
		MIDI.sharedInstance.clearListeners()
		MIDI.sharedInstance.addListener(self)
	}
	
	// MARK: Device methods
	func clearSysExResponseTimer() {
		guard let responseTimer = sysExResponseTimer else {
			return
		}
		
		responseTimer.invalidate()
		sysExResponseTimer = nil
	}
	
	func servicePendingSysExMessages(responseAction: MIDIResponseAction?) {
		guard let nextSysExMessage = pendingSysExMessages.first else {
			return
		}
		
		Proteus.midiOperationQueue.async {
			let action = responseAction ?? nextSysExMessage.responseAction
			self.send(sysExMessage: nextSysExMessage, responseAction: action)
		}
	}
	
	private func send(sysExMessage: SysExMessage, responseAction: @escaping MIDIResponseAction) {
		let command = sysExMessage.requestCommand
		
		guard let commandMessage = MIDISysExMessage(bytes: command) else {
			responseAction(.failure(Error.sysExMessageCreationFailed(sysExMessage: sysExMessage)))
			return
		}
		
		switch sysExMessage {
		case .deviceIdentity(let endpointInfo, _):
			let midi = MIDI.sharedInstance
			
			//  Close all inputs and outputs
			midi.closeAllInputsAndOutputs()
			
			// Open input and output based on provided endpoint infos
			let inMIDIUniqueID = endpointInfo.source?.midiUniqueID ?? 0
			midi.openInput(uid: inMIDIUniqueID)
			midi.openOutput(uid: endpointInfo.destination.midiUniqueID)
			
		default:
			break
		}
		
		MIDI.sharedInstance.sendMessage(commandMessage.data)
		clearSysExResponseTimer()
		
		let responseTimer = Timer(timeInterval: Self.messageTimeoutDuration, repeats: false, block: { [weak self] timer in
			DispatchQueue.main.async {
				switch self?.pendingSysExMessages.firstIndex(of: sysExMessage) {
				case .some(let messageIndex):
					// We've waited for a response but not received one after the timeout duration.
					// Remove the sys ex message from the array and complete with error.
					self?.pendingSysExMessages.remove(at: messageIndex)
					responseAction(.failure(Error.sysExMessageResponseTimedOut(sysExMessage: sysExMessage)))
					self?.servicePendingSysExMessages(responseAction: nil)
					
				case .none:
					// If the request message is no longer in the array then
					// assume it was removed because a response was received.
					break
				}
			}
		})
		
		RunLoop.main.add(responseTimer, forMode: RunLoop.Mode.default)
		sysExResponseTimer = responseTimer
	}
	
	func requestDeviceIdentities(responseAction: @escaping MIDIResponseAction) {
		print("Attempting device identities retrieval...")
		
		pendingSysExMessages.removeAll()
		
		for (destinationInfoIndex, destinationInfo) in MIDI.sharedInstance.destinationInfos.enumerated() {
			let inputInfo = MIDI.sharedInstance.inputInfos[safe: destinationInfoIndex]
			let endpointInfos = BiDirectionalEndpointInfo(source: inputInfo, destination: destinationInfo)
			let sysExMessage: SysExMessage = .deviceIdentity(endpointInfos: endpointInfos, responseAction: responseAction)
			pendingSysExMessages.append(sysExMessage)
		}
		
		servicePendingSysExMessages(responseAction: responseAction)
	}
	
	func requestHardwareConfiguration(responseAction: @escaping MIDIResponseAction) {
		print("Attempting hardware configuration retrieval...")
		
		let sysExMessage: SysExMessage = .hardwareConfiguration(responseAction: responseAction)
		pendingSysExMessages.append(sysExMessage)
		servicePendingSysExMessages(responseAction: responseAction)
	}
	
	func requestGenericNames(for objectType: ObjectType, rom: ROM, responseAction: @escaping MIDIResponseAction) {
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
		
		let nameIndexes = Array(0..<nameCount)
		let romID = MIDIWord(rom.id)
		let sysExMessages = nameIndexes.map({ SysExMessage.genericName(type: objectType, objectID: MIDIWord($0), romID: romID, responseAction: responseAction) })
		
		pendingSysExMessages = sysExMessages
		servicePendingSysExMessages(responseAction: responseAction)
	}
}
