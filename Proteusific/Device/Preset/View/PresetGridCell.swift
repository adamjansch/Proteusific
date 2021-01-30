//
//  PresetGridCell.swift
//  Proteusific
//
//  Created by Adam Jansch on 30/01/2021.
//

import SwiftUI

struct PresetGridCell: View {
	// MARK: - PROPERTIES
	// MARK: Stored properties
	let preset: Preset
	
	// MARK: View properties
	var body: some View {
		let presetTitle = preset.title ?? ""
		Text("Preset: " + presetTitle)
	}
}

//struct PresetGridCell_Previews: PreviewProvider {
//	static var previews: some View {
//		PresetGridCell()
//	}
//}
