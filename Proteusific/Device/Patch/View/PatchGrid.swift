//
//  PatchGrid.swift
//  Proteusific
//
//  Created by Adam Jansch on 04/01/2021.
//

import SwiftUI
import AudioKit

struct PatchGrid: View {
	var body: some View {
		VStack {
			Button("Retrieve Patches", action: {
				Proteus.midiOperationQueue.async {
					Proteus.shared.retrievePatches(responseAction: { result in
						DispatchQueue.main.async {
							switch result {
							case .failure(let error):
								print("Error: \(error)")
								
							case .success(let midiResponse):
								print("Success: \(midiResponse)")
							}
						}
					})
				}
			})
		}
	}
}

struct PatchGrid_Previews: PreviewProvider {
	static var previews: some View {
		PatchGrid()
	}
}
