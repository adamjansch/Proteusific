//
//  AppInfoAcknowledgementsRow.swift
//  Proteusific
//
//  Created by Adam Jansch on 20/06/2022.
//

import SwiftUI

struct AppInfoAcknowledgementsRow: View {
	// MARK: - PROPERTIES
	// MARK: Stored properties
	let acknowledgement: Acknowledgement
	
	// MARK: View properties
	var body: some View {
		HStack(alignment: .top, spacing: 12.0) {
			if let logoImage = acknowledgement.logo {
				logoImage
					.resizable()
					.frame(width: 60.0, height: 60.0)
					.cornerRadius(12.0)
			}
			
			VStack(alignment: .leading) {
				Text(acknowledgement.title)
					.font(.system(size: 21.0))
				
				if let websiteURL = URL(string: acknowledgement.website) {
					Link(acknowledgement.website, destination: websiteURL)
						.foregroundColor(Color(.systemBlue))
				}
				
				Text(acknowledgement.role)
					.foregroundColor(Color(.systemGray))
			}
		}
	}
}

struct AppInfoAcknowledgementsRow_Previews: PreviewProvider {
	static var previews: some View {
		AppInfoAcknowledgementsRow(acknowledgement: .audioKit)
	}
}
