//
//  MIDISettingsList.swift
//  Proteusific
//
//  Created by Adam Jansch on 08/12/2020.
//

import SwiftUI
import AudioKit

struct MIDISettingsList: View {
	// MARK: - ENUMS
	// MARK: Data source enums
	private enum SettingsGroup: Int, Identifiable, CaseIterable {
		case midiConnections
		
		
		// MARK: - PROPERTIES
		// MARK: Identifiable properties
		var id: Int {
			return rawValue
		}
		
		// MARK: Computed properties
		var settings: [Setting] {
			switch self {
			case .midiConnections:
				return [.midiInConnection, .midiOutConnection]
			}
		}
		
		var headerTitle: String {
			switch self {
			case .midiConnections:
				return "MIDI Connections"
			}
		}
	}
	
	enum Setting: Int, Identifiable {
		case midiInConnection
		case midiOutConnection
		
		
		// MARK: - PROPERTIES
		// MARK: Identifiable properties
		var id: Int {
			return rawValue
		}
		
		// MARK: Computed properties
		var navigationBarTitle: String {
			switch self {
			case .midiInConnection:
				return "MIDI In Connection"
			case .midiOutConnection:
				return "MIDI Out Connection"
			}
		}
		
		var title: String {
			switch self {
			case .midiInConnection:
				return "MIDI In"
			case .midiOutConnection:
				return "MIDI Out"
			}
		}
		
		var endpointInfos: [EndpointInfo] {
			switch self {
			case .midiInConnection:
				return MIDI.sharedInstance.inputInfos
			case .midiOutConnection:
				return MIDI.sharedInstance.destinationInfos
			}
		}
	}
	
	
	// MARK: - PROPERTIES
	// MARK: Stored properties
	private var settings = Settings.current
	
	// MARK: View properties
	var body: some View {
		NavigationView {
			List {
				ForEach(SettingsGroup.allCases) { section in
					let footer = HStack {
						Spacer()
						Button("Connect", action: {
							do {
								try Proteus.shared.retrieveDeviceInfo()
								
							} catch {
								print("Error connecting to device: \(error)")
							}
						})
					}
					
					Section(header: Text(section.headerTitle), footer: footer) {
						ForEach(section.settings) { setting in
							MIDISettingsMIDIConnectionRow(setting: setting)
								.environmentObject(settings)
						}
					}
				}
			}
			.listStyle(InsetGroupedListStyle())
			.navigationBarTitle("MIDI Settings")
		}
	}
}
