//
//  MIDIDeviceSelectorList.swift
//  Proteusific
//
//  Created by Adam Jansch on 07/12/2020.
//

import SwiftUI

struct MIDIDeviceSelectorList: View {
	// MARK: - PROPERTIES
	// MARK: Wrapper properties
	@EnvironmentObject private var settings: Settings
	
	// MARK: Stored properties
	let setting: MIDISettingsList.Setting
	
	// MARK: View properties
	var body: some View {
		List {
			Section {
				ForEach(MIDIManager.shared.availableDevices) { device in
					MIDIDeviceSelectorRow(setting: setting, device: device)
				}
			}
		}
		.listStyle(InsetGroupedListStyle())
		.navigationBarTitle(setting.navigationBarTitle)
	}
}
