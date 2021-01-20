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
				let columns: [GridItem] = [GridItem(.flexible(), spacing: 16.0)]
				
				LazyVGrid(columns: columns, alignment: .leading) {
					ForEach(currentDeviceROMs) { rom in
						Section(header: Text("ROM 1 - " + rom.simm.name).font(.title)) {
							let retrievePresetsAction = {
								retrievePresets(for: rom)
							}
							
							let romPresets: [String] = []
							
							switch romPresets.isEmpty {
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
								EmptyView()
							}
						}
					}
				}
				.padding(24.0)
				
				Spacer()
			}
		}
	}
	
	
	// MARK: - METHODS
	// MARK: MIDI methods
	private func retrieveHardwareConfiguration() {
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
							
							// TODO: Collect preset names
						}
						
					} catch {
						print("Error: \(error)")
					}
				}
			})
		}
	}
	
	private func retrievePresets(for rom: ROM) {
		Proteus.midiOperationQueue.async {
			Proteus.shared.requestGenericNames(for: .preset, from: rom, responseAction: { result in
				DispatchQueue.main.async {
					do {
						switch result {
						case .failure(let error):
							throw error
							
						case .success(let midiResponse):
							guard let currentDevice = User.current?.currentDevice else {
								return
							}
							
							let genericName = try Proteus.GenericName(data: midiResponse)
							print(genericName)
						}
						
					} catch {
						print("Error: \(error)")
					}
				}
			})
		}
	}
}

//struct PresetGrid_Previews: PreviewProvider {
//	static var previews: some View {
//		PresetGrid()
//	}
//}
