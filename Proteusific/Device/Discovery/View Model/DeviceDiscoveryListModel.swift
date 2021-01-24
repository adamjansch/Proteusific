//
//  DeviceDiscoveryListModel.swift
//  Proteusific
//
//  Created by Adam Jansch on 28/12/2020.
//

import SwiftUI
import AudioKit

final class DeviceDiscoveryListModel: ObservableObject {
	// MARK: - PROPERTIES
	// MARK: Wrapper properties
	@Published private(set) var discoveredDeviceResults: [MIDIResponseResult] = []
	@Published private(set) var discoveryCompleted = false
	
	// MARK: - METHODS
	// MARK: Discovery methods
	func beginDeviceDiscovery() {
		discoveredDeviceResults.removeAll()
		
		Proteus.shared.requestDeviceIdentities(responseAction: { result in
			DispatchQueue.main.async { [weak self] in
				guard let strongSelf = self else {
					return
				}
				
				let handleError: (Proteus.Error) -> Void = { error in
					print("Error Requesting Device Identity: \(error.debugMessage)")
					strongSelf.discoveredDeviceResults.append(.failure(error))
				}
				
				switch result {
				case .failure(let error):
					handleError(error)
					
				case .success(let payload):
					do {
						guard let endpointInfo = payload.endpointInfos else {
							handleError(Proteus.Error.endpointInfoNil)
							return
						}
						
						let deviceIdentity = try Proteus.DeviceIdentity(data: payload.midiResponse, endpointInfo: endpointInfo)
						strongSelf.discoveredDeviceResults.append(.success(deviceIdentity))
						
					} catch {
						handleError(Proteus.Error.other(error: error))
					}
				}
				
				if strongSelf.discoveredDeviceResults.count == MIDI.sharedInstance.destinationInfos.count {
					strongSelf.discoveryCompleted = true
				}
			}
		})
	}
}
