//
//  Collection+Utilities.swift
//  Proteusific
//
//  Created by Adam Jansch on 18/12/2020.
//

extension Collection {
	// Returns the element at the specified index if it is within bounds, otherwise nil.
	// See https://stackoverflow.com/a/30593673.
	subscript (safe index: Index) -> Element? {
		return indices.contains(index) ? self[index] : nil
	}
}
