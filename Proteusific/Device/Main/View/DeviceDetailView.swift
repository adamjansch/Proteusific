//
//  DeviceDetailView.swift
//  Proteusific
//
//  Created by Adam Jansch on 03/01/2021.
//

import SwiftUI

struct DeviceDetailView: View {
	// MARK: - ENUMS
	// MARK: Data source enums
	private enum Tab: Int, CaseIterable, Identifiable {
		case multis
		case presets
		case master
		
		var id: Int {
			return rawValue
		}
		
		var title: String {
			switch self {
			case .multis:
				return "Multis"
			case .presets:
				return "Presets"
			case .master:
				return "Master"
			}
		}
		
		var imageSystemName: String {
			switch self {
			case .multis:
				return "square.grid.3x3.fill"
			case .presets:
				return "square.dashed.inset.fill"
			case .master:
				return "slider.horizontal.below.rectangle"
			}
		}
	}
	
	
	// MARK: - PROPERTIES
	// MARK: Wrapper properties
	@State private var tabSelection = 0
	
	// MARK: View properties
	var body: some View {
		switch User.current?.currentDevice?.name {
		case .some(let deviceName):
			VStack {
				TabView(selection: $tabSelection) {
					ForEach(Tab.allCases) { tab in
						switch tab {
						case .multis:
							MultiGrid()
								.tabItem {
									Image(systemName: tab.imageSystemName)
									Text(tab.title)
								}
							
						case .presets:
							PresetGrid()
								.tabItem {
									Image(systemName: tab.imageSystemName)
									Text(tab.title)
								}
							
						case .master:
							MasterView()
								.tabItem {
									Image(systemName: tab.imageSystemName)
									Text(tab.title)
								}
						}
					}
				}
			}
			.navigationBarTitle(deviceName, displayMode: .inline)
			
		case .none:
			EmptyView()
		}
	}
}
