//
//  AppInfoBannerRow.swift
//  Proteusific
//
//  Created by Adam Jansch on 02/01/2021.
//

import SwiftUI

struct AppInfoBannerRow: View {
	// MARK: - PROPERTIES
	// MARK: View properties
	var body: some View {
		HStack(spacing: 12.0) {
			let iconDimension: CGFloat = 96.0
			
			Image("AppIconRounded")
				.resizable()
				.frame(width: iconDimension, height: iconDimension)
			
			VStack(alignment: .leading, spacing: 6.0) {
				Text("Proteusific")
					.font(.system(size: 24.0, weight: .bold))
				
				VStack(alignment: .leading) {
					if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
						Text("Version " + version)
					}
					
					if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
						Text("Build " + build)
					}
				}
			}
		}
		.listRowBackground(Color(.systemGroupedBackground))
	}
}
