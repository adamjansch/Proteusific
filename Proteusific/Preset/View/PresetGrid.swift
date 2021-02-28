//
//  PresetGrid.swift
//  Proteusific
//
//  Created by Adam Jansch on 04/01/2021.
//

import SwiftUI
import AudioKit

struct PresetGrid: View {
	// MARK: - PROPERTIES
	// MARK: Stored properties
	let part: Part
	
	// MARK: Wrapper properties
	@Environment(\.managedObjectContext) private var viewContext
	
	@FetchRequest(
		entity: ROM.entity(),
		sortDescriptors: [NSSortDescriptor(keyPath: \ROM.id, ascending: true)]
	) var roms: FetchedResults<ROM>
	
	// MARK: View properties
	var body: some View {
		VStack(alignment: .leading) {
			let currentDeviceROMs: [ROM] = roms.filter({ $0.device == User.current?.currentDevice })
			
			switch currentDeviceROMs.isEmpty {
			case true:
				Button("Retrieve Hardware Configuration", action: {
					retrieveHardwareConfiguration()
				})
				
			case false:
				ScrollView(.vertical) {
					let columnCount = (UIDevice.current.userInterfaceIdiom == .pad) ? 3 : 2
					let columns: [GridItem] = Array(repeating: .init(), count: columnCount)
					
					LazyVGrid(columns: columns, alignment: .leading, spacing: 8.0) {
						ForEach(currentDeviceROMs) { rom in
							let retrievePresetsAction = {
								retrievePresets(for: rom)
							}
							
							Section(header: PresetGridSectionHeader(rom: rom, retrievePresetsAction: retrievePresetsAction)) {
								ForEach(rom.presets) { preset in
									PresetGridCell(preset: preset, channel: part.channel)
										.background(Color(.systemGray5))
										.cornerRadius(8.0)
								}
							}
						}
					}
					.padding(24.0)
				}
				
				Spacer()
			}
		}
		.navigationTitle("Part " + String(format: "%02d", part.channel + 1))
	}
	
	
	// MARK: - METHODS
	// MARK: MIDI methods
	private func retrieveHardwareConfiguration() {
		Proteus.shared.requestHardwareConfiguration(responseAction: { result in
			DispatchQueue.main.async {
				do {
					switch result {
					case .failure(let error):
						throw error
						
					case .success(let payload):
						guard let currentDevice = User.current?.currentDevice else {
							return
						}
						
						let hardwareConfiguration = try Proteus.HardwareConfiguation(data: payload.midiResponse)
						
						for configurationROM in hardwareConfiguration.roms {
							let rom = ROM(rom: configurationROM)
							currentDevice.addToStoredROMs(rom)
						}
						
						currentDevice.userPresetCount = Int32(hardwareConfiguration.userPresetCount)
						try viewContext.save()
					}
					
				} catch {
					print("Error: \(error)")
				}
			}
		})
	}
	
	private func retrievePresets(for rom: ROM) {
		Proteus.shared.requestGenericNames(for: .preset, rom: rom, responseAction: { result in
			/*
			This closure is called for each Generic Name response received
			*/
			DispatchQueue.main.async {
				do {
					switch result {
					case .failure(let error):
						throw error
						
					case .success(let midiPayload):
						let genericName = try Proteus.GenericName(data: midiPayload.midiResponse)
						let preset = try Preset(genericName: genericName)
						rom.addToStoredPresets(preset)
					}
					
					if rom.presetCount == rom.presets.count {
						// All presets have been created
						try viewContext.save()
					}
					
				} catch {
					print("Error: \(error)")
				}
			}
		})
	}
}

//struct PresetGrid_Previews: PreviewProvider {
//	static var previews: some View {
//		PresetGrid()
//	}
//}
