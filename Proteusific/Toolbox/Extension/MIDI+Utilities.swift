//
//  MIDI+Utilities.swift
//  Proteusific
//
//  Created by Adam Jansch on 16/01/2021.
//

import AudioKit

extension MIDI {
	func closeAllInputsAndOutputs() {
		inputUIDs.forEach({ closeInput(uid: $0) })
		destinationUIDs.forEach({ closeOutput(uid: $0) })
	}
}
