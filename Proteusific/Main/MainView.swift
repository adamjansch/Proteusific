//
//  MainView.swift
//  Proteusific
//
//  Created by Adam Jansch on 07/12/2020.
//

import SwiftUI

struct MainView: View {
	// MARK: - ENUMS
	// MARK: Data source enums
	private enum ListSection: Int, Identifiable, CaseIterable {
		case midiDevices
		
		
		// MARK: - PROPERTIES
		// MARK: Identifiable properties
		var id: Int {
			return rawValue
		}
		
		// MARK: Computed properties
		var items: [ListItem] {
			switch self {
			case .midiDevices:
				return [.midiInDevice, .midiOutDevice]
			}
		}
		
		var headerTitle: String {
			switch self {
			case .midiDevices:
				return "MIDI Devices"
			}
		}
	}
	
	private enum ListItem: Int, Identifiable {
		case midiInDevice
		case midiOutDevice
		
		
		// MARK: - PROPERTIES
		// MARK: Identifiable properties
		var id: Int {
			return rawValue
		}
		
		// MARK: Computed properties
		var title: String {
			switch self {
			case .midiInDevice:
				return "MIDI In"
			case .midiOutDevice:
				return "MIDI Out"
			}
		}
		
		var context: MIDIDeviceSelector.Context {
			switch self {
			case .midiInDevice:
				return .midiIn
			case .midiOutDevice:
				return .midiOut
			}
		}
	}
	
	
	// MARK: - PROPERTIES
	// MARK: View properties
	var body: some View {
		NavigationView {
			List {
				ForEach(ListSection.allCases) { section in
					Section(header: Text(section.headerTitle)) {
						ForEach(section.items) { item in
							NavigationLink(destination: MIDIDeviceSelector(context: item.context)) {
								HStack {
									Text(item.title)
									Spacer()
									Text("None")
										.foregroundColor(.gray)
								}
							}
						}
					}
				}
			}
			.listStyle(InsetGroupedListStyle())
			.navigationBarTitle("MIDI Settings")
		}
	}
}
