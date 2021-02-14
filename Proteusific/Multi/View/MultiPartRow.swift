//
//  MultiPartRow.swift
//  Proteusific
//
//  Created by Adam Jansch on 14/02/2021.
//

import SwiftUI

struct MultiPartRow: View {
	// MARK: - PROPERTIES
	// MARK: Stored properties
	var part: Part
	
	// MARK: View properties
	var body: some View {
		HStack(alignment: .top, spacing: 12.0) {
			Text(String(format: "%02d", part.index + 1))
				.frame(width: 22.0, alignment: .trailing)
				.foregroundColor(.gray)
				.padding(EdgeInsets(top: 1.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
			
			VStack(alignment: .leading, spacing: 2.0) {
				let presetTitle = part.preset?.title ?? ""
				Text(presetTitle)
					.font(.system(size: 25.0))
				
				HStack(spacing: 4.0) {
					Text("Vol: \(part.volume)")
					Text("Pan: \(part.pan)")
				}
				.foregroundColor(.gray)
				
				Text("Output: \(part.mixOutput)")
					.foregroundColor(.gray)
			}
			
			Spacer()
			
			VStack(alignment: .trailing, spacing: 2.0) {
				let romTitle = part.rom?.simm.name ?? "-"
				Text(romTitle)
					.padding(EdgeInsets(top: 1.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
				
				if let partPreset = part.preset {
					HStack(alignment: .top, spacing: 0) {
						Text(String(format: "%03d", partPreset.presetID % 128 ))
							.font(.system(size: 20.0))
						
						Text(String(partPreset.presetID / 128 ))
							.font(.system(size: 14.0))
					}
				}
			}
		}
	}
}

//struct MultiPartRow_Previews: PreviewProvider {
//	static var previews: some View {
//		MultiPartRow()
//	}
//}
