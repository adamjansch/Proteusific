//
//  AddDeviceDiscoveryListModel.swift
//  Proteusific
//
//  Created by Adam Jansch on 28/12/2020.
//

import SwiftUI
import AudioKit

final class AddDeviceDiscoveryListModel: ObservableObject {
	// MARK: - PROPERTIES
	// MARK: Stored properties
	@Published private(set) var discoveredDeviceResults: [MIDIResponseResult]?
	
	// MARK: Wrapper properties
	//@Binding var requestDeviceIdentityError: Proteus.Error? = nil
	
	
	// MARK: - METHODS
	// MARK: Discovery methods
	func beginDeviceDiscovery() {
		discoveredDeviceResults = nil
		
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
					
					if strongSelf.discoveredDeviceResults == nil {
						strongSelf.discoveredDeviceResults = []
					}
					
					strongSelf.discoveredDeviceResults?.append(.failure(error))
				}
				
				DispatchQueue.main.async {
					switch result {
					case .failure(let error):
						handleError(error)
						
					case .success(let midiResponse):
						print("MIDI response: \(midiResponse)")
						
						do {
							if strongSelf.discoveredDeviceResults == nil {
								strongSelf.discoveredDeviceResults = []
							}
							
							let deviceIdentity = try Proteus.DeviceIdentity(data: midiResponse, endpointInfo: combinedEndpointInfo)
							strongSelf.discoveredDeviceResults?.append(.success(deviceIdentity))
							
						} catch {
							handleError(Proteus.Error.other(error: error))
						}
					}
				}
				
				dispatchGroup.leave()
			})
		}
		
		dispatchGroup.notify(queue: DispatchQueue.main, execute: {
			print("Discovered devices: \(String(describing: self.discoveredDeviceResults))")
		})
	}
}
