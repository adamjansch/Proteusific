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
						AppInfoAcknowledgementsRow(acknowledgement: acknowledgement)
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
