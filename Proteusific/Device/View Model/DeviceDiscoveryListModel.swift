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
		
		Proteus.midiOperationQueue.async { [weak self] in
			let dispatchGroup = DispatchGroup()
			
			for (destinationInfoIndex, destinationInfo) in MIDI.sharedInstance.destinationInfos.enumerated() {
				dispatchGroup.enter()
				
				let inputInfo = MIDI.sharedInstance.inputInfos[safe: destinationInfoIndex]
				let combinedEndpointInfo = BiDirectionalEndpointInfo(source: inputInfo, destination: destinationInfo)
				
				Proteus.shared.requestDeviceIdentity(endpointInfo: combinedEndpointInfo, responseAction: { [weak self] result in
					guard let strongSelf = self else {
						dispatchGroup.leave()
						return
					}
					
					let handleError: (Proteus.Error) -> Void = { error in
						print("Error Requesting Device Identity: \(error.debugMessage)")
						strongSelf.discoveredDeviceResults.append(.failure(error))
					}
					
					DispatchQueue.main.async {
						switch result {
						case .failure(let error):
							handleError(error)
							
						case .success(let midiResponse):
							print("MIDI response: \(midiResponse)")
							
							do {
								let deviceIdentity = try Proteus.DeviceIdentity(data: midiResponse, endpointInfo: combinedEndpointInfo)
								strongSelf.discoveredDeviceResults.append(.success(deviceIdentity))
								
							} catch {
								handleError(Proteus.Error.other(error: error))
							}
						}
					}
					
					dispatchGroup.leave()
				})
			}
			
			dispatchGroup.notify(queue: DispatchQueue.main) {
				self?.discoveryCompleted = true
			}
		}
	}
}
