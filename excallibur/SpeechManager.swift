//
//  SpeechManager.swift
//  excallibur
//
//  Created by Raidel Almeida on 7/31/24.
//

import AVFoundation
import Foundation
import UIKit

class SpeechManager {
		static let shared = SpeechManager()
		private var synthesizer = AVSpeechSynthesizer()

		private init() {}

		func announceCount(_ count: Int, isHaptic: Bool, isVoiceEnabled: Bool, voiceType: String, voiceSpeed: Double) {
				DispatchQueue.main.async {
						if isHaptic {
								let impact = UIImpactFeedbackGenerator(style: .medium)
								impact.impactOccurred()
						}

						if isVoiceEnabled {
								let ssml = "<speak>\(count)</speak>"
								let utterance = AVSpeechUtterance(ssmlRepresentation: ssml)!
								utterance.voice = AVSpeechSynthesisVoice(language: voiceType)
								utterance.rate = Float(voiceSpeed)
								self.synthesizer.speak(utterance)
						}
				}
		}
}
