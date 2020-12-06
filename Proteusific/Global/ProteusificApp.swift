//
//  ProteusificApp.swift
//  Proteusific
//
//  Created by Adam Jansch on 06/12/2020.
//

import SwiftUI

@main
struct ProteusificApp: App {
	// MARK: - PROPERTIES
	// MARK: Stored properties
	let persistenceController = PersistenceController.shared
	
	// MARK: Computed properties
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environment(\.managedObjectContext, persistenceController.container.viewContext)
		}
	}
	
	
	// MARK: - METHODS
	// MARK: Initializers
	init() {
		print("Available devices: \(MIDIManager.shared.availableDevices.compactMap({ $0.name }))")
	}
}
