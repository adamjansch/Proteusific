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
		case sysExMessageCreationFailed(bytes: [MIDIByte])
	}
	
	
	// MARK: - PROPERTIES
	// MARK: Shared instance
	static let shared = Proteus()
	
	// MARK: Type properties
	private static var midiOperationQueueLabel = "MIDIOperationQueue"
	private static var midiOperationQueue = DispatchQueue(label: midiOperationQueueLabel, qos: .userInitiated)
	
	// MARK: Stored properties
	private var deviceID: MIDIByte = SysexMessage.allBroadcastID
	
	
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
	func retrieveDeviceInfo() throws {
		print("Attempting device info retrieval...")
		
		Self.midiOperationQueue.async { [weak self] in
			guard let strongSelf = self else {
				return
			}
			
			strongSelf.sendDeviceInquiry(completion: { result in
				
			})
		}
	}
	
	private func sendDeviceInquiry(completion: (Result<Void, Swift.Error>) -> Void) {
		let deviceInquiryMessageMIDIBytes = SysexMessage.deviceInquiry(deviceID: deviceID).midiBytes
		
		guard let deviceInquiryMessage = MIDISysExMessage(bytes: deviceInquiryMessageMIDIBytes) else {
			completion(.failure(Error.sysExMessageCreationFailed(bytes: deviceInquiryMessageMIDIBytes)))
			return
		}
		
		MIDI.sharedInstance.sendMessage(deviceInquiryMessage.data)
		
		// TODO: Replace this with the MIDI situation
		completion(.success(()))
	}
}
