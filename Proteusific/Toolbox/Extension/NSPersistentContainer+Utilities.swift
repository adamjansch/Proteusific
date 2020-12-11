//
//  NSPersistentContainer+Utilities.swift
//  Proteusific
//
//  Created by Adam Jansch on 09/12/2020.
//

import CoreData

extension NSPersistentContainer {
	func saveContext() {
		guard viewContext.hasChanges else {
			return
		}
		
		do {
			try viewContext.save()
			
		} catch {
			print("UNABLE TO SAVE MANAGED OBJECT CONTEXT: \(viewContext)")
		}
	}
}
