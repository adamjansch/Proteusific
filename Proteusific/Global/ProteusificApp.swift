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
		if let uid = Settings.current.midiInUID,
		   MIDI.sharedInstance.inputInfos.contains(where: { uid.int32Value == $0.midiUniqueID }) {
			MIDI.sharedInstance.openInput(uid: uid.int32Value)
		}
		
		if let uid = Settings.current.midiOutUID,
		   MIDI.sharedInstance.destinationInfos.contains(where: { uid.int32Value == $0.midiUniqueID }) {
			MIDI.sharedInstance.openOutput(uid: uid.int32Value)
		}
	}
}
