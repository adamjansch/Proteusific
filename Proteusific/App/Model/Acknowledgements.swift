//
//  Acknowledgements.swift
//  Proteusific
//
//  Created by Adam Jansch on 02/01/2021.
//

import SwiftUI

enum AcknowledgementGroup: Int, CaseIterable, Identifiable {
	case contributors
	case code
	
	// MARK: Identifiable properties
	var id: Int {
		return rawValue
	}
	
	// MARK: Computed properties
	var headerTitle: String {
		switch self {
		case .contributors:
			return "Contributors"
		case .code:
			return "Code"
		}
	}
	
	var acknowledgements: [Acknowledgement] {
		switch self {
		case .contributors:
			return [.adamJansch]
		case .code:
			return [.audioKit]
		}
	}
}


enum Acknowledgement: Int, Identifiable {
	case adamJansch
	case audioKit
	
	// MARK: Identifiable properties
	var id: Int {
		return rawValue
	}
	
	// MARK: Computed properties
	var role: String {
		switch self {
		case .adamJansch:
			return "Creator"
		case .audioKit:
			return "iOS Library"
		}
	}
	
	var title: String {
		switch self {
		case .adamJansch:
			return "Adam Jansch"
		case .audioKit:
			return "AudioKit"
		}
	}
	
	var website: String {
		switch self {
		case .adamJansch:
			return "https://adamjansch.co.uk"
		case .audioKit:
			return "https://audiokit.io/"
		}
	}
	
	var logo: Image? {
		switch self {
		case .adamJansch:
			return Image("AJ logo")
		case .audioKit:
			return Image("AudioKit logo")
		}
	}
}
