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
	// MARK: Type properties
	static var isDebug: Bool {
		#if DEBUG
			return true
		#else
			return false
		#endif
	}
	
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
		if let currentUser = User.current,
		   let currentDevice = currentUser.currentDevice {
			currentUser.updateEndpoints(with: currentDevice)
		}
		
		Proteus.shared.configure()
	}
}
