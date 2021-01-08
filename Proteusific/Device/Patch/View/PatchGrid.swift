//
//  PatchGrid.swift
//  Proteusific
//
//  Created by Adam Jansch on 04/01/2021.
//

import SwiftUI
import AudioKit

struct PatchGrid: View {
	// MARK: - PROPERTIES
	// MARK: Wrapper properties
	@Environment(\.managedObjectContext) private var viewContext
	
	// MARK: View properties
	var body: some View {
		VStack {
			Button("Retrieve Patches", action: {
				Proteus.midiOperationQueue.async {
					Proteus.shared.requestHardwareConfiguration(responseAction: { result in
						DispatchQueue.main.async {
							do {
								switch result {
								case .failure(let error):
									throw error
									
								case .success(let midiResponse):
									guard let currentDevice = User.current?.currentDevice else {
										return
									}
									
									let hardwareConfiguration = try Proteus.HardwareConfiguation(data: midiResponse)
									
									for configurationROM in hardwareConfiguration.roms {
										let rom = ROM(rom: configurationROM)
										currentDevice.addToRoms(rom)
									}
									
									currentDevice.userPresetCount = Int32(hardwareConfiguration.userPresetCount)
									
									try viewContext.save()
									
									// TODO: Collection preset names
								}
								
							} catch {
								print("Error: \(error)")
							}
						}
					})
				}
			})
		}
	}
}

//struct PatchGrid_Previews: PreviewProvider {
//	static var previews: some View {
//		PatchGrid()
//	}
//}
