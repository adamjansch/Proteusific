//
//  DataMappable.swift
//  Proteusific
//
//  Created by Adam Jansch on 11/02/2021.
//

import AudioKit

protocol DataMappable {
	func bool(from unprocessedMIDIBytes: [MIDIByte]) throws -> Bool
	func midiWord(from unprocessedMIDIBytes: [MIDIByte]) throws -> MIDIWord
}

extension DataMappable where Self: RawRepresentable, Self.RawValue == Int {
	func bool(from unprocessedMIDIBytes: [MIDIByte]) throws -> Bool {
		let byteIndex = rawValue * 2
		let valueBytes = Array(unprocessedMIDIBytes[byteIndex ... byteIndex + 1])
		return Bool(midiWord: try MIDIWord(unprocessedMIDIBytes: valueBytes))
	}
	
	func midiWord(from unprocessedMIDIBytes: [MIDIByte]) throws -> MIDIWord {
		let byteIndex = rawValue * 2
		let valueBytes = Array(unprocessedMIDIBytes[byteIndex ... byteIndex + 1])
		return try MIDIWord(unprocessedMIDIBytes: valueBytes)
	}
}
