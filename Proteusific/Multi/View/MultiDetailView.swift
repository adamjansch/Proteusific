//
//  MultiDetailView.swift
//  Proteusific
//
//  Created by Adam Jansch on 07/02/2021.
//

import SwiftUI

struct MultiDetailView: View {
	// MARK: - PROPERTIES
	// MARK: Stored properties
	var device: Device
	
	// MARK: Wrapper properties
	@Environment(\.managedObjectContext) private var viewContext
	
	// MARK: View properties
	var body: some View {
		switch device.currentMulti {
		case .some(let currentMulti):
			List {
				Section {
					ForEach(currentMulti.sortedParts) { part in
						MultiPartRow(part: part)
							.padding(EdgeInsets(top: 12.0, leading: 4.0, bottom: 12.0, trailing: 4.0))
							.cornerRadius(5.0)
					}
				}
			}
			.listStyle(InsetGroupedListStyle())
			
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
						let multi = try Multi(currentSetupDump: currentSetupDump)
						device.currentMulti = multi
						
						try viewContext.save()
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
