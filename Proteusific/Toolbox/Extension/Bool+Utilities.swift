//
//  Bool+Utilities.swift
//  Proteusific
//
//  Created by Adam Jansch on 09/02/2021.
//

import AudioKit

extension Bool {
	init(midiWord: MIDIWord) {
		self = (midiWord != 0)
	}
}
