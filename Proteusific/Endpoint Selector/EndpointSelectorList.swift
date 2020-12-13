//
//  EndpointSelectorList.swift
//  Proteusific
//
//  Created by Adam Jansch on 07/12/2020.
//

import SwiftUI
import AudioKit
import CoreMIDI

struct EndpointSelectorList: View {
	// MARK: - PROPERTIES
	// MARK: Wrapper properties
	@EnvironmentObject private var settings: Settings
	
	// MARK: Stored properties
	let setting: MIDISettingsList.Setting
	
	// MARK: View properties
	var body: some View {
		List {
			Section {
				ForEach(setting.endpointInfos) { destination in
					EndpointSelectorRow(setting: setting, endpointInfo: destination)
				}
			}
		}
		.listStyle(InsetGroupedListStyle())
		.navigationBarTitle(setting.navigationBarTitle)
	}
}

extension EndpointInfo: Identifiable {
	public var id: MIDIObjectRef {
		return midiEndpointRef
	}
}
