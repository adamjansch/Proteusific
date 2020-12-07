//
//  MIDIManager.swift
//  Proteusific
//
//  Created by Adam Jansch on 06/12/2020.
//

import Foundation
import UIKit
import CoreMIDI

final class MIDIManager {
	// MARK: - TYPE PROPERTIES
	// MARK: Shared instance property
	static let shared = MIDIManager()
	
	// MARK: Stored properties
	private(set) var availableDevices: [MIDIDevice] = []
	
	
	// MARK: - METHODS
	// MARK: Initialisers
	private init() {
		retrieveAvailableDevices()
		
		NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: Notification methods
	@objc private func appDidBecomeActive(_ notification: Notification) {
		retrieveAvailableDevices()
	}
	
	// MARK: MIDI methods
	private func retrieveAvailableDevices() {
		let deviceIndexes = 0 ..< MIDIGetNumberOfDevices()
		let availableDevices: [MIDIDevice] = deviceIndexes.compactMap({ deviceIndex in
			let deviceRef = MIDIGetDevice(deviceIndex)
			let device = MIDIDevice(objectRef: deviceRef)
			return (device.online) ? device : nil
		})
		
		self.availableDevices = availableDevices
	}
}
