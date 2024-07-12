//  Created by Raidel Almeida on 6/30/24.
//
//  SettingsView.swift
//  excallibur
//
//

import SwiftUI
import AVFoundation

struct SettingsView: View {
    @AppStorage("isHapticFeedbackEnabled") private var isHapticFeedbackEnabled = true
    @AppStorage("isVoiceFeedbackEnabled") private var isVoiceFeedbackEnabled = true
    @AppStorage("selectedVoiceType") private var selectedVoiceType = "en-US"
    @AppStorage("voiceSpeed") private var voiceSpeed: Double = 0.5
    @AppStorage("motionSensitivity") private var motionSensitivity: Double = 0.3
    @AppStorage("useButtonForTracking") private var useButtonForTracking = true
    @AppStorage("showSensorReading") private var showSensorReading = false
    

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Feedback")) {
                    Toggle("Haptic Feedback", isOn: $isHapticFeedbackEnabled)
                        .onChange(of: isHapticFeedbackEnabled) { newValue in
                        if newValue {
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                    }
                    Toggle("Voice Feedback", isOn: $isVoiceFeedbackEnabled)
                }

                Section(header: Text("Voice Settings")) {
                    Picker("Voice Type", selection: $selectedVoiceType) {
                        ForEach(AVSpeechSynthesisVoice.speechVoices().compactMap { $0.language }, id: \.self) { voice in
                            Text(voice).tag(voice)
                        }
                    }
                        .pickerStyle(.menu)

                    Slider(value: $voiceSpeed, in: 0.1...1.0, step: 0.1) {
                        Text("Voice Speed")
                    } minimumValueLabel: {
                        Text("Slow")
                    } maximumValueLabel: {
                        Text("Fast")
                    }
                        .accessibilityValue(String(format: "%.1f", voiceSpeed))

                    Button("Preview Voice") {
                        previewVoice()
                    }
                }

                Section(header: Text("Tracking")) {
                    Toggle("Use Button for Tracking", isOn: $useButtonForTracking)
                    Toggle("Show Sensor Reading", isOn: $showSensorReading)

                    Slider(value: $motionSensitivity, in: 0.05...0.5, step: 0.05) {
                        Text("Motion Sensitivity")
                    } minimumValueLabel: {
                        Text("Low")
                    } maximumValueLabel: {
                        Text("High")
                    }
                        .accessibilityValue(String(format: "%.2f", motionSensitivity)) }

                Section {
                    Button("Reset to Defaults") {
                        resetToDefaults()
                    }
                        .foregroundColor(.red)
                }

                Section {
                    Text("App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
                .navigationTitle("Settings")
        }
    }

    private func previewVoice() {
        let utterance = AVSpeechUtterance(string: "This is a preview of the selected voice and speed.")
        utterance.voice = AVSpeechSynthesisVoice(language: selectedVoiceType)
        utterance.rate = Float(voiceSpeed)

        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }

    private func resetToDefaults() {
        isHapticFeedbackEnabled = true
        isVoiceFeedbackEnabled = true
        selectedVoiceType = "en-US"
        voiceSpeed = 1.0
    }
}
