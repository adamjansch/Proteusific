//
//  MIDISettingsRow.swift
//  Proteusific
//
//  Created by Adam Jansch on 08/12/2020.
//

import SwiftUI

protocol MIDISettingsRow: View {
	var setting: MIDISettingsList.Setting { get }
}
