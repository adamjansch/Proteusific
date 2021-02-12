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
			case fxBypass
			case transpose
			case tune
			case bendRange
			case velocityCurve
			case outputFormat
			case knobQuickEdit
			case knobDeepEdit
			case presetEditAllLayers
			case demoModeEnable
		}
		
		
		// MARK: - PROPERTIES
		// MARK: Stored properties
		let bendRange: MIDIWord
		let clockTempo: MIDIWord
		let demoModeEnable: Bool
		let fxBypass: Bool
		let knobDeepEdit: Bool
		let knobQuickEdit: Bool
		let outputFormat: MIDIWord
		let presetEditAllLayers: Bool
		let transpose: MIDIWord
		let tune: MIDIWord
		let velocityCurve: MIDIWord
		
		
		// MARK: - METHODS
		// MARK: Initialisers
		init(midiBytes: [MIDIByte], parameterCount: MIDIWord) throws {
			/*
			BYTES (by index)
			0:	Master Clock Tempo
			1:	Master FX Bypass
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
			demoModeEnable = try DataMap.demoModeEnable.bool(from: midiBytes)
			fxBypass = try DataMap.fxBypass.bool(from: midiBytes)
			knobDeepEdit = try DataMap.knobDeepEdit.bool(from: midiBytes)
			knobQuickEdit = try DataMap.knobQuickEdit.bool(from: midiBytes)
			outputFormat = try DataMap.outputFormat.midiWord(from: midiBytes)
			presetEditAllLayers = try DataMap.presetEditAllLayers.bool(from: midiBytes)
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
			case modeChangeMasterMIDIID
			case aControl
			case bControl
			case cControl
			case dControl
			case eControl
			case fControl
			case gControl
			case hControl
			case fs1Control
			case fs2Control
			case fs3Control
			case tempoCtrlUp
			case tempoCtrlDown
			case knobOut
			case packetDelay
			case iControl
			case jControl
			case kControl
			case lControl
		}
		
		
		// MARK: - PROPERTIES
		// MARK: Stored properties
		let fs1Control: MIDIWord
		let fs2Control: MIDIWord
		let fs3Control: MIDIWord
		let knobOut: MIDIWord
		let mode: MIDIWord
		let modeChangeMasterMIDIID: MIDIWord
		let packetDelay: MIDIWord
		let tempoCtrlDown: MIDIWord
		let tempoCtrlUp: MIDIWord
		
		let aControl: MIDIWord
		let bControl: MIDIWord
		let cControl: MIDIWord
		let dControl: MIDIWord
		let eControl: MIDIWord
		let fControl: MIDIWord
		let gControl: MIDIWord
		let hControl: MIDIWord
		let iControl: MIDIWord
		let jControl: MIDIWord
		let kControl: MIDIWord
		let lControl: MIDIWord
		
		
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
			
			fs1Control = try DataMap.fs1Control.midiWord(from: midiBytes)
			fs2Control = try DataMap.fs2Control.midiWord(from: midiBytes)
			fs3Control = try DataMap.fs3Control.midiWord(from: midiBytes)
			knobOut = try DataMap.knobOut.midiWord(from: midiBytes)
			mode = try DataMap.mode.midiWord(from: midiBytes)
			modeChangeMasterMIDIID = try DataMap.modeChangeMasterMIDIID.midiWord(from: midiBytes)
			packetDelay = try DataMap.packetDelay.midiWord(from: midiBytes)
			tempoCtrlDown = try DataMap.tempoCtrlDown.midiWord(from: midiBytes)
			tempoCtrlUp = try DataMap.tempoCtrlUp.midiWord(from: midiBytes)
			
			aControl = try DataMap.aControl.midiWord(from: midiBytes)
			bControl = try DataMap.bControl.midiWord(from: midiBytes)
			cControl = try DataMap.cControl.midiWord(from: midiBytes)
			dControl = try DataMap.dControl.midiWord(from: midiBytes)
			eControl = try DataMap.eControl.midiWord(from: midiBytes)
			fControl = try DataMap.fControl.midiWord(from: midiBytes)
			gControl = try DataMap.gControl.midiWord(from: midiBytes)
			hControl = try DataMap.hControl.midiWord(from: midiBytes)
			iControl = try DataMap.iControl.midiWord(from: midiBytes)
			jControl = try DataMap.jControl.midiWord(from: midiBytes)
			kControl = try DataMap.kControl.midiWord(from: midiBytes)
			lControl = try DataMap.lControl.midiWord(from: midiBytes)
		}
	}
	
	struct MasterEffectsParameters {
		// MARK: - ENUMS
		// MARK: Map enums
		private enum DataMap: Int, DataMappable {
			case fxAAlgorithm
			case fxADecay
			case fxAHFDamp
			case fxAToB
			case fxAMixMain
			case fxAMixSub1
			case fxAMixSub2
			case fxBAlgorithm
			case fxBFeedback
			case fxBLFORate
			case fxBDelay
			case fxBMixMain
			case fxBMixSub1
			case fxBMixSub2
			case fxAMixSub3
			case fxBMixSub3
		}
		
		
		// MARK: - PROPERTIES
		// MARK: Stored properties
		let fxAAlgorithm: MIDIWord
		let fxADecay: MIDIWord
		let fxAHFDamp: MIDIWord
		let fxAToB: MIDIWord
		let fxAMixMain: MIDIWord
		let fxAMixSub1: MIDIWord
		let fxAMixSub2: MIDIWord
		let fxAMixSub3: MIDIWord
		
		let fxBAlgorithm: MIDIWord
		let fxBDelay: MIDIWord
		let fxBFeedback: MIDIWord
		let fxBLFORate: MIDIWord
		let fxBMixMain: MIDIWord
		let fxBMixSub1: MIDIWord
		let fxBMixSub2: MIDIWord
		let fxBMixSub3: MIDIWord
		
		
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
			fxAToB = try DataMap.fxAToB.midiWord(from: midiBytes)
			fxAMixMain = try DataMap.fxAMixMain.midiWord(from: midiBytes)
			fxAMixSub1 = try DataMap.fxAMixSub1.midiWord(from: midiBytes)
			fxAMixSub2 = try DataMap.fxAMixSub2.midiWord(from: midiBytes)
			fxAMixSub3 = try DataMap.fxAMixSub3.midiWord(from: midiBytes)
			
			fxBAlgorithm = try DataMap.fxBAlgorithm.midiWord(from: midiBytes)
			fxBDelay = try DataMap.fxBDelay.midiWord(from: midiBytes)
			fxBFeedback = try DataMap.fxBFeedback.midiWord(from: midiBytes)
			fxBLFORate = try DataMap.fxBLFORate.midiWord(from: midiBytes)
			fxBMixMain = try DataMap.fxBMixMain.midiWord(from: midiBytes)
			fxBMixSub1 = try DataMap.fxBMixSub1.midiWord(from: midiBytes)
			fxBMixSub2 = try DataMap.fxBMixSub2.midiWord(from: midiBytes)
			fxBMixSub3 = try DataMap.fxBMixSub3.midiWord(from: midiBytes)
		}
	}
	
	struct NonChannelParameters {
		// MARK: - ENUMS
		// MARK: Map enums
		private enum DataMap: Int, DataMappable {
			case multimodeBasicChannel
			case multimodeFXCtrlChannel
			case multimodeTempoCtrlChannel
		}
		
		
		// MARK: - PROPERTIES
		// MARK: Stored properties
		let multimodeBasicChannel: MIDIWord
		let multimodeFXCtrlChannel: MIDIWord
		let multimodeTempoCtrlChannel: MIDIWord
		
		
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
			multimodeFXCtrlChannel = try DataMap.multimodeFXCtrlChannel.midiWord(from: midiBytes)
			multimodeTempoCtrlChannel = try DataMap.multimodeTempoCtrlChannel.midiWord(from: midiBytes)
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
