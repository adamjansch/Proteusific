//
//  PresetGridSectionHeader.swift
//  Proteusific
//
//  Created by Adam Jansch on 31/01/2021.
//

import SwiftUI

struct PresetGridSectionHeader: View {
	// MARK: - PROPERTIES
	// MARK: Stored properties
	let rom: ROM
	let retrievePresetsAction: () -> Void
	
	// MARK: View properties
	var body: some View {
		VStack {
			let bottomPadding: CGFloat = 16.0
			
			switch User.current?.currentDevice?.roms.firstIndex(of: rom) {
			case .some(let romIndex):
				Text("ROM " + String(romIndex + 1) + " - " + rom.simm.name)
					.font(.title)
					.padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: bottomPadding, trailing: 0.0))
				
			case .none:
				Text("ROM - " + rom.simm.name)
					.font(.title)
					.padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: bottomPadding, trailing: 0.0))
			}
			
			if rom.presets.isEmpty {
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
			}
		}
	}
}

//struct PresetGridSectionHeader_Previews: PreviewProvider {
//	static var previews: some View {
//		PresetGridSectionHeader()
//	}
//}
