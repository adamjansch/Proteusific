//
//  EndpointInfo+Identifiable.swift
//  Proteusific
//
//  Created by Adam Jansch on 18/12/2020.
//

import AudioKit
import CoreMIDI

extension EndpointInfo: Identifiable {
	public var id: MIDIObjectRef {
		return midiEndpointRef
	}
}
