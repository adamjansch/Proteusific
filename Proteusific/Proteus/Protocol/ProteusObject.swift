//
//  ProteusObject.swift
//  Proteusific
//
//  Created by Adam Jansch on 24/01/2021.
//

protocol ProteusObject {
	var objectType: Proteus.ObjectType { get }
	var category: Proteus.PresetCategory { get set }
}
