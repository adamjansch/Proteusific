//
//  AppInfoList.swift
//  Proteusific
//
//  Created by Adam Jansch on 02/01/2021.
//

import SwiftUI

struct AppInfoList: View {
	// MARK: - PROPERTIES
	// MARK: Wrapper properties
	@Binding var showAppInfoList: Bool
	
	// MARK: View properties
	var body: some View {
		let closeButton = Button("Close", action: {
			showAppInfoList = false
		})
		
		NavigationView {
			List {
				ForEach(AppInfo.Section.allSections) { section in
					let sectionTitle = section.title ?? ""
					
					Section(header: Text(sectionTitle)) {
						ForEach(section.options) { option in
							switch option {
							case .banner:
								AppInfoBannerRow()
								
							case .acknowledgements:
								NavigationLink(destination: AppInfoAcknowledgementsList()) {
									Text(option.mainText)
								}
								
							case .getHelp:
								if let issuesURL = URL(string: "https://github.com/adamjansch/Proteusific/issues") {
									Link(option.mainText, destination: issuesURL)
										.foregroundColor(Color(.label))
									
								} else {
									Text(option.mainText)
								}
								
							default:
								Text(option.mainText)
							}
						}
					}
				}
			}
			.listStyle(InsetGroupedListStyle())
			.navigationBarTitle("Proteusific", displayMode: .inline)
			.navigationBarItems(leading: closeButton)
		}
	}
}
