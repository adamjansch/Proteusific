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
		let buttonAction = {
			Proteus.shared.changePreset(to: preset)
		}
		
		Button(action: buttonAction, label: {
			HStack {
				VStack(alignment: .leading, spacing: 2.0) {
					let presetMetaFontSize: CGFloat = (UIDevice.current.userInterfaceIdiom == .pad) ? 18.0 : 15.0
					HStack(spacing: 4.0) {
						HStack(alignment: .top, spacing: 1.0) {
							Text(String(format: "%03d", preset.presetID % 128))
							Text(String(preset.presetID / 128))
								.font(.system(size: 11.0))
						}
						
						Text("|")
							.foregroundColor(Color(.systemGray3))
						
						Text(preset.category.title)
					}
					.foregroundColor(Color(.systemGray))
					.font(.system(size: presetMetaFontSize))
					
					let presetTitle = preset.title ?? ""
					let presetTitleFontSize: CGFloat = (UIDevice.current.userInterfaceIdiom == .pad) ? 24.0 : 17.0
					Text(presetTitle)
						.font(.system(size: presetTitleFontSize))
						.foregroundColor(Color(.white))
				}
				.padding(12.0)
				
				Spacer()
			}
		})
	}
}

//struct PresetGridCell_Previews: PreviewProvider {
//	static var previews: some View {
//		PresetGridCell()
//	}
//}
