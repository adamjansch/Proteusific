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
					let columns: [GridItem] = [GridItem(.flexible(), spacing: 16.0)]
					
					LazyVGrid(columns: columns, alignment: .leading) {
						ForEach(currentDeviceROMs) { rom in
							Section(header: Text("ROM 1 - " + rom.simm.name).font(.title)) {
								let retrievePresetsAction = {
									retrievePresets(for: rom)
								}
								
								switch rom.presets.isEmpty {
								case true:
									Button(action: retrievePresetsAction, label: {
										HStack {
											Image(systemName: "square.and.arrow.down.fill")
												.font(.system(size: 48.0))
											
											VStack(alignment: .leading) {
												Text("Retrieve presets from").font(.system(size: 21.0))
												Text(rom.simm.name).font(.system(size: 32.0))
											}
										}
									})
									.padding(EdgeInsets(top: 16.0, leading: 4.0, bottom: 16.0, trailing: 4.0))
									
								case false:
									ForEach(rom.presets) { preset in
										PresetGridCell(preset: preset)
									}
								}
							}
						}
					}
					.padding(24.0)
				}
				
				Spacer()
			}
		}
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
							currentDevice.addToRoms(rom)
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
