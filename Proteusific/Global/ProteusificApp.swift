//
//  ProteusificApp.swift
//  Proteusific
//
//  Created by Adam Jansch on 06/12/2020.
//

import SwiftUI
import AudioKit

@main
struct ProteusificApp: App {
	// MARK: - PROPERTIES
	// MARK: Stored properties
	let persistenceController = PersistenceController.shared
	
	// MARK: Computed properties
	var body: some Scene {
		WindowGroup {
			MainView()
				.environment(\.managedObjectContext, persistenceController.container.viewContext)
		}
	}
	
	
	// MARK: - METHODS
	// MARK: Initializers
	init() {
		print("MIDI Sources:      \(MIDI.sharedInstance.inputInfos)")
		print("MIDI Destinations: \(MIDI.sharedInstance.destinationInfos)")
		
		// MIDI configuration
		Proteus.shared.configure()
	}
}
