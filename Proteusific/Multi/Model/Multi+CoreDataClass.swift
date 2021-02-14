//
//  Multi+CoreDataClass.swift
//  Proteusific
//
//  Created by Adam Jansch on 07/02/2021.
//
//

import CoreData

public class Multi: NSManagedObject {
	// MARK: - PROPERTIES
	// MARK: Computed properties
	var sortedParts: [Part] {
		let indexSortDescriptor = NSSortDescriptor(key: "index", ascending: true)
		return parts?.sortedArray(using: [indexSortDescriptor]) as? [Part] ?? []
	}
	
	var midiMode: MIDIMode {
		get {
			return MIDIMode(rawValue: midiModeID) ?? .omni
		}
		set {
			midiModeID = newValue.rawValue
		}
	}
	
	
	// MARK: - METHODS
	// MARK: Initializers
	convenience init(currentSetupDump: Proteus.CurrentSetupDump) throws {
		guard let currentUser = User.current,
			  let currentDevice = currentUser.currentDevice else {
			throw User.Error.currentDeviceNil
		}
		
		do {
			self.init(context: PersistenceController.shared.container.viewContext)
			
			self.device = currentDevice
			
			// Master General
			self.masterTranspose = Int16(currentSetupDump.masterGeneralParameters.transpose)
			self.masterTune = Int16(currentSetupDump.masterGeneralParameters.tune)
			self.masterClockTempo = Int16(currentSetupDump.masterGeneralParameters.clockTempo)
			self.masterBendRange = Int16(currentSetupDump.masterGeneralParameters.bendRange)
			self.masterOutputFormat = Int16(currentSetupDump.masterGeneralParameters.outputFormat)
			self.fxEnabled = currentSetupDump.masterGeneralParameters.fxEnabled
			self.knobsQuickEdit = currentSetupDump.masterGeneralParameters.knobsQuickEdit
			self.knobsDeepEdit = currentSetupDump.masterGeneralParameters.knobsDeepEdit
			self.masterVelocityCurve = Int16(currentSetupDump.masterGeneralParameters.velocityCurve)
			self.masterEditAllLayers = currentSetupDump.masterGeneralParameters.editAllLayers
			self.masterDemoModeEnabled = currentSetupDump.masterGeneralParameters.demoModeEnabled
			
			// Master MIDI
			self.midiModeID = Int16(currentSetupDump.masterMIDIParameters.mode)		// 0: Omni, 1: Poly, 2: Multi
			self.midiModeChangeAccepted = currentSetupDump.masterMIDIParameters.modeChangeAccepted
			self.knobsMIDIOut = currentSetupDump.masterMIDIParameters.knobsMIDIOut
			self.sysexPacketDelay = Int16(currentSetupDump.masterMIDIParameters.sysexPacketDelay)
			
			self.realtimeControllerA = Int16(currentSetupDump.masterMIDIParameters.realtimeControllerA)
			self.realtimeControllerB = Int16(currentSetupDump.masterMIDIParameters.realtimeControllerB)
			self.realtimeControllerC = Int16(currentSetupDump.masterMIDIParameters.realtimeControllerC)
			self.realtimeControllerD = Int16(currentSetupDump.masterMIDIParameters.realtimeControllerD)
			self.realtimeControllerE = Int16(currentSetupDump.masterMIDIParameters.realtimeControllerE)
			self.realtimeControllerF = Int16(currentSetupDump.masterMIDIParameters.realtimeControllerF)
			self.realtimeControllerG = Int16(currentSetupDump.masterMIDIParameters.realtimeControllerG)
			self.realtimeControllerH = Int16(currentSetupDump.masterMIDIParameters.realtimeControllerH)
			self.realtimeControllerI = Int16(currentSetupDump.masterMIDIParameters.realtimeControllerI)
			self.realtimeControllerJ = Int16(currentSetupDump.masterMIDIParameters.realtimeControllerJ)
			self.realtimeControllerK = Int16(currentSetupDump.masterMIDIParameters.realtimeControllerK)
			self.realtimeControllerL = Int16(currentSetupDump.masterMIDIParameters.realtimeControllerL)
			
			self.footswitchController1 = Int16(currentSetupDump.masterMIDIParameters.footswitchController1)
			self.footswitchController2 = Int16(currentSetupDump.masterMIDIParameters.footswitchController2)
			self.footswitchController3 = Int16(currentSetupDump.masterMIDIParameters.footswitchController3)
			
			self.tempoControllerUp = Int16(currentSetupDump.masterMIDIParameters.tempoControllerUp)
			self.tempoControllerDown = Int16(currentSetupDump.masterMIDIParameters.tempoControllerDown)
			
			// Master FX
			self.fxAAlgorithmID = Int16(currentSetupDump.masterEffectsParameters.fxAAlgorithm)
			self.fxADecay = Int16(currentSetupDump.masterEffectsParameters.fxADecay)
			self.fxAHFDamp = Int16(currentSetupDump.masterEffectsParameters.fxAHFDamp)
			self.fxBToA = Int16(currentSetupDump.masterEffectsParameters.fxBToA)
			self.fxASend1 = Int16(currentSetupDump.masterEffectsParameters.fxASend1)
			self.fxASend2 = Int16(currentSetupDump.masterEffectsParameters.fxASend2)
			self.fxASend3 = Int16(currentSetupDump.masterEffectsParameters.fxASend3)
			self.fxASend4 = Int16(currentSetupDump.masterEffectsParameters.fxASend4)
			
			self.fxBAlgorithmID = Int16(currentSetupDump.masterEffectsParameters.fxBAlgorithm)
			self.fxBFeedback = Int16(currentSetupDump.masterEffectsParameters.fxBFeedback)
			self.fxBLFORate = Int16(currentSetupDump.masterEffectsParameters.fxBLFORate)
			self.fxBDelay = Int16(currentSetupDump.masterEffectsParameters.fxBDelay)
			self.fxBSend1 = Int16(currentSetupDump.masterEffectsParameters.fxBSend1)
			self.fxBSend2 = Int16(currentSetupDump.masterEffectsParameters.fxBSend2)
			self.fxBSend3 = Int16(currentSetupDump.masterEffectsParameters.fxBSend3)
			self.fxBSend4 = Int16(currentSetupDump.masterEffectsParameters.fxBSend4)
			
			// Non-channel
			self.multimodeBasicChannel = Int16(currentSetupDump.nonChannelParameters.multimodeBasicChannel)
			self.multimodeFXControlChannel = Int16(currentSetupDump.nonChannelParameters.multimodeFXControlChannel)
			self.multimodeTempoControlChannel = Int16(currentSetupDump.nonChannelParameters.multimodeTempoControlChannel)
			
			// Parts
			for (channelParametersIndex, channelParameters) in currentSetupDump.partsChannelParameters.enumerated() {
				let part = try Part(channelParameters: channelParameters, index: Int16(channelParametersIndex))
				addToParts(part)
			}
			
		} catch {
			PersistenceController.shared.container.viewContext.rollback()
			throw error
		}
	}
}

extension Multi {
	enum MIDIMode: Int16 {
		case omni
		case poly
		case multi
	}
}
