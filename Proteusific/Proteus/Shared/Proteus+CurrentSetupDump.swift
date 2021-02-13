//
//  Proteus+CurrentSetupDump.swift
//  Proteusific
//
//  Created by Adam Jansch on 09/02/2021.
//

import AudioKit

extension Proteus {
	struct CurrentSetupDump {
		// MARK: - PROPERTIES
		// MARK: Type properties
		private static let setupNameCharacterCount = 16
		
		// MARK: Stored properties
		let masterGeneralParameters: MasterGeneralParameters
		let masterMIDIParameters: MasterMIDIParameters
		let masterEffectsParameters: MasterEffectsParameters
		let nonChannelParameters: NonChannelParameters
		let partsChannelParameters: [ChannelParameters]
		let title: String
		
		
		// MARK: - METHODS
		// MARK: Initialisers
		init(data: [MIDIByte]) throws {
			/*
			BYTES (by index)
			0:		Sysex message
			1:		EMU ID
			2:		Proteus ID
			3:		Device ID
			4:		Special Editor byte
			5:		Command
			6-7:	Number of Master General Parameters
			8-9:	Number of Master MIDI Parameters
			10-11:	Number of Master Effects Parameters
			12-13:	Number of Reserved Parameters
			14-15:	Number of Non Channel Parameters
			16-17:	Number of MIDI Channels
			18-19:	Number of Parameters per Channel
			20-35:	16 ASCII character Setup Name
			[]:		Master General data
			[]:		Master MIDI data
			[]:		Master Effects data
			[]:		Reserved data
			[]:		Non Channel Parameter Values
			[]:		Channel Parameters
			End:	EOX
			
			*/
			guard data[0] == SysExMessage.sysExMessageByte,
				  data[1] == SysExMessage.sysExEMUByte,
				  data[2] == SysExMessage.sysExProteusByte,
				  data[4] == SysExMessage.sysExSpecialEditorByte,
				  data[5] == SysExMessage.Command.currentSetupDumpResponse.byte else {
				throw Error.incompatibleSysExMessage(data: data)
			}
			
			var byteOffset = 6
			
			let masterGeneralParameterCountBytes = Array(data[byteOffset...byteOffset + 1])
			let masterGeneralParameterCount = try MIDIWord(unprocessedMIDIBytes: masterGeneralParameterCountBytes)
			byteOffset += MIDIWord.byteCount
			
			let masterMIDIParameterCountBytes = Array(data[byteOffset...byteOffset + 1])
			let masterMIDIParameterCount = try MIDIWord(unprocessedMIDIBytes: masterMIDIParameterCountBytes)
			byteOffset += MIDIWord.byteCount
			
			let masterEffectsParameterCountBytes = Array(data[byteOffset...byteOffset + 1])
			let masterEffectsParameterCount = try MIDIWord(unprocessedMIDIBytes: masterEffectsParameterCountBytes)
			byteOffset += MIDIWord.byteCount
			
			let reservedParameterCountBytes = Array(data[byteOffset...byteOffset + 1])
			let reservedParameterCount = try MIDIWord(unprocessedMIDIBytes: reservedParameterCountBytes)
			byteOffset += MIDIWord.byteCount
			
			let nonChannelParameterCountBytes = Array(data[byteOffset...byteOffset + 1])
			let nonChannelParameterCount = try MIDIWord(unprocessedMIDIBytes: nonChannelParameterCountBytes)
			byteOffset += MIDIWord.byteCount
			
			let midiChannelCountBytes = Array(data[byteOffset...byteOffset + 1])
			let midiChannelCount = try MIDIWord(unprocessedMIDIBytes: midiChannelCountBytes)
			byteOffset += MIDIWord.byteCount
			
			let parametersPerChannelCountBytes = Array(data[byteOffset...byteOffset + 1])
			let parametersPerChannelCount = try MIDIWord(unprocessedMIDIBytes: parametersPerChannelCountBytes)
			byteOffset += MIDIWord.byteCount
			
			let setupNameEndIndex = byteOffset + Self.setupNameCharacterCount
			let setupNameBytes = Array(data[byteOffset..<setupNameEndIndex])
			title = String(setupNameBytes.map({ Character(UnicodeScalar($0)) })).trimmingCharacters(in: .whitespacesAndNewlines)
			byteOffset += Self.setupNameCharacterCount
			
			let masterGeneralParametersByteCount = Int(masterGeneralParameterCount) * MIDIWord.byteCount
			let masterGeneralParametersBytes = Array(data[byteOffset..<byteOffset + masterGeneralParametersByteCount])
			masterGeneralParameters = try MasterGeneralParameters(midiBytes: masterGeneralParametersBytes, parameterCount: masterGeneralParameterCount)
			byteOffset += masterGeneralParametersByteCount
			
			let masterMIDIParametersByteCount = Int(masterMIDIParameterCount) * MIDIWord.byteCount
			let masterMIDIParametersBytes = Array(data[byteOffset..<byteOffset + masterMIDIParametersByteCount])
			masterMIDIParameters = try MasterMIDIParameters(midiBytes: masterMIDIParametersBytes, parameterCount: masterMIDIParameterCount)
			byteOffset += masterMIDIParametersByteCount
			
			let masterEffectsParametersByteCount = Int(masterEffectsParameterCount) * MIDIWord.byteCount
			let masterEffectsParametersBytes = Array(data[byteOffset..<byteOffset + masterEffectsParametersByteCount])
			masterEffectsParameters = try MasterEffectsParameters(midiBytes: masterEffectsParametersBytes, parameterCount: masterEffectsParameterCount)
			byteOffset += masterEffectsParametersByteCount
			
			let reservedParametersByteCount = Int(reservedParameterCount) * MIDIWord.byteCount
			// What are the reserved parameters?
			byteOffset += reservedParametersByteCount
			
			let nonChannelParametersByteCount = Int(nonChannelParameterCount) * MIDIWord.byteCount
			let nonChannelParametersBytes = Array(data[byteOffset..<byteOffset + nonChannelParametersByteCount])
			nonChannelParameters = try NonChannelParameters(midiBytes: nonChannelParametersBytes, parameterCount: nonChannelParameterCount)
			byteOffset += nonChannelParametersByteCount
			
			var partsChannelParameters: [ChannelParameters] = []
			for midiChannel in 0..<midiChannelCount {
				let channelParametersByteCount = Int(parametersPerChannelCount) * MIDIWord.byteCount
				let channelParametersBytes = Array(data[byteOffset..<byteOffset + channelParametersByteCount])
				let channelParameters = try ChannelParameters(midiBytes: channelParametersBytes, parameterCount: parametersPerChannelCount, midiChannel: MIDIChannel(midiChannel))
				byteOffset += channelParametersByteCount
				
				partsChannelParameters.append(channelParameters)
			}
			
			self.partsChannelParameters = partsChannelParameters
		}
	}
}

extension Proteus.CurrentSetupDump {
	struct MasterGeneralParameters {
		// MARK: - ENUMS
		// MARK: Map enums
		private enum DataMap: Int, DataMappable {
			case clockTempo
			case fxEnabled
			case transpose
			case tune
			case bendRange
			case velocityCurve
			case outputFormat
			case knobsQuickEdit
			case knobsDeepEdit
			case editAllLayers
			case demoModeEnabled
		}
		
		
		// MARK: - PROPERTIES
		// MARK: Stored properties
		let bendRange: MIDIWord
		let clockTempo: MIDIWord
		let demoModeEnabled: Bool
		let fxEnabled: Bool
		let knobsDeepEdit: Bool
		let knobsQuickEdit: Bool
		let outputFormat: MIDIWord
		let editAllLayers: Bool
		let transpose: MIDIWord
		let tune: MIDIWord
		let velocityCurve: MIDIWord
		
		
		// MARK: - METHODS
		// MARK: Initialisers
		init(midiBytes: [MIDIByte], parameterCount: MIDIWord) throws {
			/*
			BYTES (by index)
			0:	Master Clock Tempo
			1:	Master FX Mode
			2:	Master Transpose
			3:	Master Tune
			4:	Master Bend Range
			5:	Master Vel Curve
			6:	Master Output Format
			7:	Master Knob Quick Edit
			8:	Master Knob Deep Edit
			9:	Master Preset Edit All Layers
			10:	Master Demo Mode Enable
			11-19: - there are more, I don't know what they are
			*/
			guard (midiBytes.count / MIDIWord.byteCount) >= parameterCount else {
				throw Proteus.Error.insufficientMIDIBytes(midiBytes: midiBytes, parameterCount: parameterCount)
			}
			
			bendRange = try DataMap.bendRange.midiWord(from: midiBytes)
			clockTempo = try DataMap.clockTempo.midiWord(from: midiBytes)
			demoModeEnabled = try DataMap.demoModeEnabled.bool(from: midiBytes)
			fxEnabled = try DataMap.fxEnabled.bool(from: midiBytes)
			knobsDeepEdit = try DataMap.knobsDeepEdit.bool(from: midiBytes)
			knobsQuickEdit = try DataMap.knobsQuickEdit.bool(from: midiBytes)
			outputFormat = try DataMap.outputFormat.midiWord(from: midiBytes)
			editAllLayers = try DataMap.editAllLayers.bool(from: midiBytes)
			transpose = try DataMap.transpose.midiWord(from: midiBytes)
			tune = try DataMap.tune.midiWord(from: midiBytes)
			velocityCurve = try DataMap.velocityCurve.midiWord(from: midiBytes)
		}
	}
	
	struct MasterMIDIParameters {
		// MARK: - ENUMS
		// MARK: Map enums
		private enum DataMap: Int, DataMappable {
			case mode
			case modeChangeAccepted
			case realtimeControllerA
			case realtimeControllerB
			case realtimeControllerC
			case realtimeControllerD
			case realtimeControllerE
			case realtimeControllerF
			case realtimeControllerG
			case realtimeControllerH
			case footswitchController1
			case footswitchController2
			case footswitchController3
			case tempoControllerUp
			case tempoControllerDown
			case knobsMIDIOut
			case sysexPacketDelay
			case realtimeControllerI
			case realtimeControllerJ
			case realtimeControllerK
			case realtimeControllerL
		}
		
		
		// MARK: - PROPERTIES
		// MARK: Stored properties
		let knobsMIDIOut: Bool
		let mode: MIDIWord
		let modeChangeAccepted: Bool
		let sysexPacketDelay: MIDIWord
		let tempoControllerDown: MIDIWord
		let tempoControllerUp: MIDIWord
		
		let realtimeControllerA: MIDIWord
		let realtimeControllerB: MIDIWord
		let realtimeControllerC: MIDIWord
		let realtimeControllerD: MIDIWord
		let realtimeControllerE: MIDIWord
		let realtimeControllerF: MIDIWord
		let realtimeControllerG: MIDIWord
		let realtimeControllerH: MIDIWord
		let realtimeControllerI: MIDIWord
		let realtimeControllerJ: MIDIWord
		let realtimeControllerK: MIDIWord
		let realtimeControllerL: MIDIWord
		
		let footswitchController1: MIDIWord
		let footswitchController2: MIDIWord
		let footswitchController3: MIDIWord
		
		
		// MARK: - METHODS
		// MARK: Initialisers
		init(midiBytes: [MIDIByte], parameterCount: MIDIWord) throws {
			/*
			BYTES (by index)
			0:	Master MIDI Mode
			1:	Master MIDI Mode Change Master MIDI ID
			2:	Master MIDI A Control
			3:	Master MIDI B Control
			4:	Master MIDI C Control
			5:	Master MIDI D Control
			6:	Master MIDI E Control
			7:	Master MIDI F Control
			8:	Master MIDI G Control
			9:	Master MIDI H Control
			10:	Master MIDI FS1 Control
			11:	Master MIDI FS2 Control
			12:	Master MIDI FS3 Control
			13:	Master MIDI Tempo Ctrl Up
			14:	Master MIDI Tempo Ctrl Down
			15:	Master MIDI Knob Out
			16:	Master MIDI Packet Delay
			17:	Master MIDI I Control
			18:	Master MIDI J Control
			19:	Master MIDI K Control
			20:	Master MIDI L Control
			*/
			guard (midiBytes.count / MIDIWord.byteCount) >= parameterCount else {
				throw Proteus.Error.insufficientMIDIBytes(midiBytes: midiBytes, parameterCount: parameterCount)
			}
			
			knobsMIDIOut = try DataMap.knobsMIDIOut.bool(from: midiBytes)
			mode = try DataMap.mode.midiWord(from: midiBytes)
			modeChangeAccepted = try DataMap.modeChangeAccepted.bool(from: midiBytes)
			sysexPacketDelay = try DataMap.sysexPacketDelay.midiWord(from: midiBytes)
			tempoControllerDown = try DataMap.tempoControllerDown.midiWord(from: midiBytes)
			tempoControllerUp = try DataMap.tempoControllerUp.midiWord(from: midiBytes)
			
			realtimeControllerA = try DataMap.realtimeControllerA.midiWord(from: midiBytes)
			realtimeControllerB = try DataMap.realtimeControllerB.midiWord(from: midiBytes)
			realtimeControllerC = try DataMap.realtimeControllerC.midiWord(from: midiBytes)
			realtimeControllerD = try DataMap.realtimeControllerD.midiWord(from: midiBytes)
			realtimeControllerE = try DataMap.realtimeControllerE.midiWord(from: midiBytes)
			realtimeControllerF = try DataMap.realtimeControllerF.midiWord(from: midiBytes)
			realtimeControllerG = try DataMap.realtimeControllerG.midiWord(from: midiBytes)
			realtimeControllerH = try DataMap.realtimeControllerH.midiWord(from: midiBytes)
			realtimeControllerI = try DataMap.realtimeControllerI.midiWord(from: midiBytes)
			realtimeControllerJ = try DataMap.realtimeControllerJ.midiWord(from: midiBytes)
			realtimeControllerK = try DataMap.realtimeControllerK.midiWord(from: midiBytes)
			realtimeControllerL = try DataMap.realtimeControllerL.midiWord(from: midiBytes)
			
			footswitchController1 = try DataMap.footswitchController1.midiWord(from: midiBytes)
			footswitchController2 = try DataMap.footswitchController2.midiWord(from: midiBytes)
			footswitchController3 = try DataMap.footswitchController3.midiWord(from: midiBytes)
		}
	}
	
	struct MasterEffectsParameters {
		// MARK: - ENUMS
		// MARK: Map enums
		private enum DataMap: Int, DataMappable {
			case fxAAlgorithm
			case fxADecay
			case fxAHFDamp
			case fxBToA
			case fxASend1
			case fxASend2
			case fxASend3
			case fxBAlgorithm
			case fxBFeedback
			case fxBLFORate
			case fxBDelay
			case fxBSend1
			case fxBSend2
			case fxBSend3
			case fxASend4
			case fxBSend4
		}
		
		
		// MARK: - PROPERTIES
		// MARK: Stored properties
		let fxAAlgorithm: MIDIWord
		let fxADecay: MIDIWord
		let fxAHFDamp: MIDIWord
		let fxBToA: MIDIWord
		let fxASend1: MIDIWord
		let fxASend2: MIDIWord
		let fxASend3: MIDIWord
		let fxASend4: MIDIWord
		
		let fxBAlgorithm: MIDIWord
		let fxBDelay: MIDIWord
		let fxBFeedback: MIDIWord
		let fxBLFORate: MIDIWord
		let fxBSend1: MIDIWord
		let fxBSend2: MIDIWord
		let fxBSend3: MIDIWord
		let fxBSend4: MIDIWord
		
		
		// MARK: - METHODS
		// MARK: Initialisers
		init(midiBytes: [MIDIByte], parameterCount: MIDIWord) throws {
			/*
			BYTES (by index)
			0:	Master FX A Algorithm
			1:	Master FX A Decay
			2:	Master FX A HFDamp
			3:	Master FX A>B
			4:	Master FX A Mix Main
			5:	Master FX A Mix Sub1
			6:	Master FX A Mix Sub2
			7:	Master FX B Algorithm
			8:	Master FX B Feedback
			9:	Master FX B LFO Rate
			10:	Master FX B Delay
			11:	Master FX B Mix Main
			12:	Master FX B Mix Sub1
			13:	Master FX B Mix Sub2
			14:	Master FX A Mix Sub3
			15:	Master FX B Mix Sub3
			*/
			guard (midiBytes.count / MIDIWord.byteCount) >= parameterCount else {
				throw Proteus.Error.insufficientMIDIBytes(midiBytes: midiBytes, parameterCount: parameterCount)
			}
			
			fxAAlgorithm = try DataMap.fxAAlgorithm.midiWord(from: midiBytes)
			fxADecay = try DataMap.fxADecay.midiWord(from: midiBytes)
			fxAHFDamp = try DataMap.fxAHFDamp.midiWord(from: midiBytes)
			fxBToA = try DataMap.fxBToA.midiWord(from: midiBytes)
			fxASend1 = try DataMap.fxASend1.midiWord(from: midiBytes)
			fxASend2 = try DataMap.fxASend2.midiWord(from: midiBytes)
			fxASend3 = try DataMap.fxASend3.midiWord(from: midiBytes)
			fxASend4 = try DataMap.fxASend4.midiWord(from: midiBytes)
			
			fxBAlgorithm = try DataMap.fxBAlgorithm.midiWord(from: midiBytes)
			fxBDelay = try DataMap.fxBDelay.midiWord(from: midiBytes)
			fxBFeedback = try DataMap.fxBFeedback.midiWord(from: midiBytes)
			fxBLFORate = try DataMap.fxBLFORate.midiWord(from: midiBytes)
			fxBSend1 = try DataMap.fxBSend1.midiWord(from: midiBytes)
			fxBSend2 = try DataMap.fxBSend2.midiWord(from: midiBytes)
			fxBSend3 = try DataMap.fxBSend3.midiWord(from: midiBytes)
			fxBSend4 = try DataMap.fxBSend4.midiWord(from: midiBytes)
		}
	}
	
	struct NonChannelParameters {
		// MARK: - ENUMS
		// MARK: Map enums
		private enum DataMap: Int, DataMappable {
			case multimodeBasicChannel
			case multimodeFXControlChannel
			case multimodeTempoControlChannel
		}
		
		
		// MARK: - PROPERTIES
		// MARK: Stored properties
		let multimodeBasicChannel: MIDIWord
		let multimodeFXControlChannel: MIDIWord
		let multimodeTempoControlChannel: MIDIWord
		
		
		// MARK: - METHODS
		// MARK: Initialisers
		init(midiBytes: [MIDIByte], parameterCount: MIDIWord) throws {
			/*
			BYTES (by index)
			0:	Multimode Basic Channel
			1:	Multimode FX Ctrl Channel
			2:	Multimode Tempo Ctrl Channel
			*/
			guard (midiBytes.count / MIDIWord.byteCount) >= parameterCount else {
				throw Proteus.Error.insufficientMIDIBytes(midiBytes: midiBytes, parameterCount: parameterCount)
			}
			
			multimodeBasicChannel = try DataMap.multimodeBasicChannel.midiWord(from: midiBytes)
			multimodeFXControlChannel = try DataMap.multimodeFXControlChannel.midiWord(from: midiBytes)
			multimodeTempoControlChannel = try DataMap.multimodeTempoControlChannel.midiWord(from: midiBytes)
		}
	}
	
	struct ChannelParameters {
		// MARK: - ENUMS
		// MARK: Map enums
		private enum DataMap: Int, DataMappable {
			case presetID
			case volume
			case pan
			case mixOutput
			case reserved1
			case channelEnable
			case reserved2
			case receiveProgramChange
			case romID
		}
		
		
		// MARK: - PROPERTIES
		// MARK: Stored properties
		let channelEnable: Bool
		let mixOutput: MIDIWord
		let pan: MIDIWord
		let presetID: MIDIWord
		let receiveProgramChange: Bool
		let romID: MIDIWord
		let volume: MIDIWord
		
		
		// MARK: - METHODS
		// MARK: Initialisers
		init(midiBytes: [MIDIByte], parameterCount: MIDIWord, midiChannel: MIDIChannel) throws {
			/*
			BYTES (by index)
			0:	Multimode Preset
			1:	Multimode Volume
			2:	Multimode Pan
			3:	Multimode Mix Output
			4:	(reserved)
			5:	Multimode Channel Enable
			6:	(reserved)
			7:	Multimode Receive Program Change
			8:	Multimode Preset ROM ID
			*/
			guard (midiBytes.count / MIDIWord.byteCount) >= parameterCount else {
				throw Proteus.Error.insufficientMIDIBytes(midiBytes: midiBytes, parameterCount: parameterCount)
			}
			
			channelEnable = try DataMap.channelEnable.bool(from: midiBytes)
			mixOutput = try DataMap.mixOutput.midiWord(from: midiBytes)
			pan = try DataMap.pan.midiWord(from: midiBytes)
			presetID = try DataMap.presetID.midiWord(from: midiBytes)
			receiveProgramChange = try DataMap.receiveProgramChange.bool(from: midiBytes)
			romID = try DataMap.romID.midiWord(from: midiBytes)
			volume = try DataMap.volume.midiWord(from: midiBytes)
		}
	}
}
