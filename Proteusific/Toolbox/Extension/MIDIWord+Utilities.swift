//
//  MIDIWord+Utilities.swift
//  Proteusific
//
//  Created by Adam Jansch on 14/01/2021.
//

import AudioKit

typealias MIDIBytePair = [MIDIByte]

extension MIDIWord {
	// MARK: - ENUMS
	// MARK: Error enum
	enum Error: Swift.Error {
		case invalidByteArray([MIDIByte])
	}
	
	
	// MARK: - PROPERTIES
	// MARK: Type properties
	static let byteCount = 2
	
	// MARK: Computed properties
	var unprocessedMIDIBytes: [MIDIByte] {
		let lsb = MIDIByte(truncatingIfNeeded: self)
		let msb = MIDIByte(truncatingIfNeeded: self >> 8)
		return [lsb, msb]
	}
	
	var processedMIDIBytes: [MIDIByte] {
		let lsb = MIDIByte(self % 128)
		let msb = MIDIByte(self / 128)
		return [lsb, msb]
	}
	
	
	// MARK: - METHODS
	// MARK: Initialisers
	init(processedMIDIBytes: [MIDIByte]) throws {
		guard processedMIDIBytes.count == 2 else {
			throw Error.invalidByteArray(processedMIDIBytes)
		}
		
		let midiWord = processedMIDIBytes[0...1].withUnsafeBytes({ $0.load(as: MIDIWord.self) })
		self.init(midiWord)
	}
	
	init(unprocessedMIDIBytes: [MIDIByte]) throws {
		guard unprocessedMIDIBytes.count == 2 else {
			throw Error.invalidByteArray(unprocessedMIDIBytes)
		}
		
		let lsb = unprocessedMIDIBytes[0]
		let msb = unprocessedMIDIBytes[1]
		self.init(MIDIWord(lsb) + (MIDIWord(msb) << 7))
	}
}
