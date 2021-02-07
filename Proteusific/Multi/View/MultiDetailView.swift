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
				print("Retrieving Current Multi...")
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
}

//struct MultiDetailView_Previews: PreviewProvider {
//	static var previews: some View {
//		MultiDetailView()
//	}
//}
