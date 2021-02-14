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
		HStack(alignment: .top, spacing: 8.0) {
			Text("\(part.index + 1).")
			
			VStack(alignment: .leading) {
				HStack {
					let presetTitle = part.preset?.title ?? ""
					Text(presetTitle)
					
					Spacer()
					
					let romTitle = part.rom?.simm.name ?? ""
					Text(romTitle)
				}
				
				Text("Vol: \(part.volume)")
				Text("Pan: \(part.pan)")
				Text("Output: \(part.mixOutput)")
			}
		}
	}
}

//struct MultiPartRow_Previews: PreviewProvider {
//	static var previews: some View {
//		MultiPartRow()
//	}
//}
