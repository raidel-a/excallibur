//
//  SettingsView.swift
//

import AVFoundation
import SwiftUI
import DataProvider

struct SettingsView: View {
	@StateObject private var viewModel = SettingsViewModel()
	@Environment(\.createDataHandler) private var createDataHandler
	
	var body: some View {
		NavigationView {
			Form {
				Section(header: Text("Feedback")) {
					Toggle("Haptic Feedback", isOn: $viewModel.isHapticFeedbackEnabled)
						.onChange(of: viewModel.isHapticFeedbackEnabled) { _, newValue in
							if newValue {
								UIImpactFeedbackGenerator(style: .medium).impactOccurred()
							}
						}
					Toggle("Voice Feedback", isOn: $viewModel.isVoiceFeedbackEnabled)
				}
				
				Section(header: Text("Voice Settings")) {
					Picker("Voice Type", selection: $viewModel.selectedVoiceType) {
						ForEach(AVSpeechSynthesisVoice.speechVoices().compactMap(\.language), id: \.self) { voice in
							Text(voice).tag(voice)
						}
					}
					.pickerStyle(.menu)
					
					Slider(value: $viewModel.voiceSpeed, in: 0.1...1.0, step: 0.1) {
						Text("Voice Speed")
					} minimumValueLabel: {
						Text("Slow")
					} maximumValueLabel: {
						Text("Fast")
					}
					.accessibilityValue(String(format: "%.1f", viewModel.voiceSpeed))
					
					Button("Preview Voice") {
						viewModel.previewVoice()
					}
				}
				
				Section(header: Text("Tracking")) {
					Toggle("Use Button for Tracking", isOn: $viewModel.useButtonForTracking)
					Toggle("Show Sensor Reading", isOn: $viewModel.showSensorReading)
					
					Slider(value: $viewModel.motionSensitivity, in: 0.05...0.5, step: 0.05) {
						Text("Motion Sensitivity")
					} minimumValueLabel: {
						Text("Low")
					} maximumValueLabel: {
						Text("High")
					}
					.accessibilityValue(String(format: "%.2f", viewModel.motionSensitivity))
				}
				
				Section {
					Button("Reset to Defaults") {
						viewModel.resetToDefaults()
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
		.task {
			await viewModel.loadSettings(createDataHandler: createDataHandler)
		}
	}
}

class SettingsViewModel: ObservableObject {
	@Published var isHapticFeedbackEnabled: Bool = UserDefaults.standard.bool(forKey: "isHapticFeedbackEnabled")
	@Published var isVoiceFeedbackEnabled: Bool = UserDefaults.standard.bool(forKey: "isVoiceFeedbackEnabled")
	@Published var selectedVoiceType: String = UserDefaults.standard.string(forKey: "selectedVoiceType") ?? "en-US"
	@Published var voiceSpeed: Double = UserDefaults.standard.double(forKey: "voiceSpeed")
	@Published var motionSensitivity: Double = UserDefaults.standard.double(forKey: "motionSensitivity")
	@Published var useButtonForTracking: Bool = UserDefaults.standard.bool(forKey: "useButtonForTracking")
	@Published var showSensorReading: Bool = UserDefaults.standard.bool(forKey: "showSensorReading")
	
	private let synthesizer = AVSpeechSynthesizer()
	
	func loadSettings(createDataHandler: @escaping () async -> DataHandler?) async {
			// Here you can load any additional settings from SwiftData if needed
			// For example:
			// if let dataHandler = await createDataHandler() {
			//     let someSettingFromSwiftData = try? await dataHandler.getSomeSetting()
			//     // Update the appropriate @Published property
			// }
	}
	
	func previewVoice() {
		let utterance = AVSpeechUtterance(string: "This is a preview of the selected voice and speed.")
		utterance.voice = AVSpeechSynthesisVoice(language: selectedVoiceType)
		utterance.rate = Float(voiceSpeed)
		synthesizer.speak(utterance)
	}
	
	func resetToDefaults() {
		isHapticFeedbackEnabled = true
		isVoiceFeedbackEnabled = true
		selectedVoiceType = "en-US"
		voiceSpeed = 0.5
		motionSensitivity = 0.3
		useButtonForTracking = true
		showSensorReading = false
		saveSettings()
	}
	
	private func saveSettings() {
		UserDefaults.standard.set(isHapticFeedbackEnabled, forKey: "isHapticFeedbackEnabled")
		UserDefaults.standard.set(isVoiceFeedbackEnabled, forKey: "isVoiceFeedbackEnabled")
		UserDefaults.standard.set(selectedVoiceType, forKey: "selectedVoiceType")
		UserDefaults.standard.set(voiceSpeed, forKey: "voiceSpeed")
		UserDefaults.standard.set(motionSensitivity, forKey: "motionSensitivity")
		UserDefaults.standard.set(useButtonForTracking, forKey: "useButtonForTracking")
		UserDefaults.standard.set(showSensorReading, forKey: "showSensorReading")
	}
}
