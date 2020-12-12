//
//  MIDIManager.swift
//  Proteusific
//
//  Created by Adam Jansch on 06/12/2020.
//

import Foundation
import UIKit
import CoreMIDI

enum MIDIError: Error {
	case midiDestinationEndpointNil
	case midiEventSendFailed(status: OSStatus)
	case midiOutputPortNil
	case midiPortCreateFailed(status: OSStatus)
}

final class MIDIManager {
	// MARK: - TYPE PROPERTIES
	// MARK: Shared instance property
	static let shared = MIDIManager()
	
	// MARK: Stored properties
	private(set) lazy var availableDevices: [MIDIDevice] = retrieveAvailableDevices()
	
	// MARK: Lazy properties
	private var privateClient: MIDIClientRef?
	private var client: MIDIClientRef? {
		switch privateClient {
		case .some(let client):
			return client
			
		default:
			var clientRef = MIDIClientRef()
			let clientName = "Proteusific" as CFString
			
			let status = MIDIClientCreateWithBlock(clientName, &clientRef, clientNotifyBlock)
			guard status == noErr else {
				print("Could not create MIDI client: \(status)")
				return nil
			}
			
			privateClient = clientRef
			return clientRef
		}
	}
	
	private lazy var clientNotifyBlock: MIDINotifyBlock = {
		return { notification in
			
		}
	}()
	
	private var privateOutputPort: MIDIOutputPort?
	private var outputPort: MIDIOutputPort? {
		switch privateOutputPort {
		case .some(let outputPort):
			return outputPort
			
		default:
			guard let midiClient = client else {
				return nil
			}
			
			do {
				let outputPort = try MIDIOutputPort(clientRef: midiClient)
				privateOutputPort = outputPort
				return outputPort
				
			} catch {
				print("Could not create MIDI port: \(error)")
				return nil
			}
		}
	}
	
	
	// MARK: - METHODS
	// MARK: Initialisers
	private init() {
		NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: Notification methods
	@objc private func appDidBecomeActive(_ notification: Notification) {
		availableDevices = retrieveAvailableDevices()
	}
	
	// MARK: MIDI methods
	private func retrieveAvailableDevices() -> [MIDIDevice] {
		let deviceIndexes = 0 ..< MIDIGetNumberOfDevices()
		let availableDevices: [MIDIDevice] = deviceIndexes.compactMap({ deviceIndex in
			let deviceRef = MIDIGetDevice(deviceIndex)
			let device = MIDIDevice(objectRef: deviceRef)
			return (device.online) ? device : nil
		})
		
		return availableDevices
	}
	
	private func send(protocolID: MIDIProtocolID) throws {
		guard let midiOutputPort = outputPort else {
			throw MIDIError.midiOutputPortNil
		}
		
		guard let destinationEndpoint = Settings.current.midiOutDevice?.entities.first?.destinationEndpoints.first else {
			throw MIDIError.midiDestinationEndpointNil
		}
		
		let eventPacketTimeStamp = MIDITimeStamp(mach_absolute_time())
//		let eventPacket = MIDIEventPacket(timeStamp: eventPacketTimeStamp, wordCount: <#T##UInt32#>, words: <#T##(UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32, UInt32)#>)
//
//		var eventList = MIDIEventList(protocol: protocolID, numPackets: 1, packet: eventPacket)
//		let status = MIDISendEventList(midiOutputPort.portRef, destinationEndpoint.objectRef, &eventList)
//		if status != noErr {
//			throw MIDIError.midiEventSendFailed(status: status)
//		}
	}
}
