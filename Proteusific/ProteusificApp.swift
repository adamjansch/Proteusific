//
//  ProteusificApp.swift
//  Proteusific
//
//  Created by Adam Jansch on 06/12/2020.
//

import SwiftUI

@main
struct ProteusificApp: App {
	let persistenceController = PersistenceController.shared
	
	var body: some Scene {
		WindowGroup {
			ContentView()
				.environment(\.managedObjectContext, persistenceController.container.viewContext)
		}
	}
}
