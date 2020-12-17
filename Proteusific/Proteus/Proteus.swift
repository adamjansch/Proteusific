//
//  Proteus.swift
//  Proteusific
//
//  Created by Adam Jansch on 13/12/2020.
//

import Foundation
import AudioKit
import CoreMIDI

final class Proteus {
	// MARK: - ENUMS
	// MARK: Error enum
	enum Error: Swift.Error {
		case incompatibleSysExMessage(data: [MIDIByte])
		case sysExMessageCreationFailed(sysexMessage: SysExMessage)
	}
	
	
	// MARK: - PROPERTIES
	// MARK: Shared instance
	static let shared = Proteus()
	
	// MARK: Type properties
	private static var midiOperationQueueLabel = "MIDIOperationQueue"
	private static var midiOperationQueue = DispatchQueue(label: midiOperationQueueLabel, qos: .userInitiated)
	
	// MARK: Stored properties
	private var deviceID: MIDIByte = SysExMessage.allBroadcastID
	var currentSysexMessage: SysExMessage?
	
	var currentMIDIInError: Swift.Error? {
		didSet {
			guard let midiInError = currentMIDIInError else {
				return
			}
			
			// Do something with error here
			print("MIDI in error: \(midiInError)")
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
	func requestDeviceIdentity(completion: @escaping (Result<Void, Swift.Error>) -> Void) {
		print("Attempting device info retrieval...")
		
		Self.midiOperationQueue.async { [weak self] in
			guard let strongSelf = self else {
				return
			}
			
			do {
				try strongSelf.sendDeviceInquiry()
				// This call should be picked up in `receivedMIDISystemCommand()`
				
				DispatchQueue.main.async {
					completion(.success(()))
				}
				
			} catch {
				DispatchQueue.main.async {
					completion(.failure(error))
				}
			}
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
	
	private func sendDeviceInquiry() throws {
		let deviceInquirySysexMessage = SysExMessage.deviceInquiry(deviceID: deviceID)
		let deviceInquirySysexMessageMIDIBytes = deviceInquirySysexMessage.midiBytes
		
		guard let deviceInquiryMessage = MIDISysExMessage(bytes: deviceInquirySysexMessageMIDIBytes) else {
			throw Error.sysExMessageCreationFailed(sysexMessage: deviceInquirySysexMessage)
		}
		
		currentSysexMessage = deviceInquirySysexMessage
		MIDI.sharedInstance.sendMessage(deviceInquiryMessage.data)
	}
}
