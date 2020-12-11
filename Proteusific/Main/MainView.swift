//
//  MainView.swift
//  Proteusific
//
//  Created by Adam Jansch on 07/12/2020.
//

import SwiftUI

struct MainView: View {
	// MARK: - PROPERTIES
	// MARK: Wrapper properties
	@Environment(\.managedObjectContext) private var viewContext
	
	// MARK: View properties
	var body: some View {
		MIDISettingsList()
			.environment(\.managedObjectContext, viewContext)
	}
}
