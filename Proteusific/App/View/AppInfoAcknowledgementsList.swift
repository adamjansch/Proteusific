//
//  AppInfoAcknowledgementsList.swift
//  Proteusific
//
//  Created by Adam Jansch on 02/01/2021.
//

import SwiftUI

struct AppInfoAcknowledgementsList: View {
	// MARK: - PROPERTIES
	// MARK: View properties
	var body: some View {
		List {
			ForEach(AcknowledgementGroup.allCases) { acknowledgementGroup in
				Section(header: Text(acknowledgementGroup.headerTitle)) {
					ForEach(acknowledgementGroup.acknowledgements) { acknowledgement in
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
						.padding(EdgeInsets(top: 8.0, leading: 0.0, bottom: 8.0, trailing: 0.0))
					}
				}
			}
		}
		.listStyle(InsetGroupedListStyle())
		.navigationTitle("Acknowledgements")
		.padding(EdgeInsets(top: 24.0, leading: 0.0, bottom: 0.0, trailing: 0.0))
	}
}
