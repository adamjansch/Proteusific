//
//  MultiDetailView.swift
//  Proteusific
//
//  Created by Adam Jansch on 07/02/2021.
//

import SwiftUI

struct MultiDetailView: View {
	// MARK: - PROPERTIES
	// MARK: Wrapper properties
	var device: Device
	
	// MARK: View properties
	var body: some View {
		switch device.currentMulti {
		case .some(let currentMulti):
			EmptyView()
			
		case .none:
			let retrieveCurrentMultiAction = {
				retrieveCurrentSetupDump()
			}
			
			VStack {
				Button(action: retrieveCurrentMultiAction, label: {
					VStack {
						Image(systemName: "square.and.arrow.down.fill")
							.font(.system(size: 48.0))
						
						VStack(alignment: .leading) {
							Text("Retrieve Current Multi").font(.system(size: 21.0))
						}
					}
				})
				.padding(EdgeInsets(top: 16.0, leading: 4.0, bottom: 16.0, trailing: 4.0))
				
				Spacer()
			}
		}
	}
	
	// MARK: - METHODS
	// MARK: MIDI methods
	private func retrieveCurrentSetupDump() {
		Proteus.shared.requestCurrentSetupDump(responseAction: { result in
			DispatchQueue.main.async {
				do {
					switch result {
					case .failure(let error):
						throw error
						
					case .success(let payload):
						let currentSetupDump = try Proteus.CurrentSetupDump(data: payload.midiResponse)
						print(currentSetupDump)
						
					}
					
				} catch {
					print("Error: \(error)")
				}
			}
		})
	}
}

//struct MultiDetailView_Previews: PreviewProvider {
//	static var previews: some View {
//		MultiDetailView()
//	}
//}
