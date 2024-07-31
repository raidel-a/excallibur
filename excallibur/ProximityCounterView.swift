//
//  ProximityCounterView.swift
//

//import AVFoundation
//import Combine
import DataProvider
import SwiftData
import SwiftUI
//import UIKit

// MARK: - ProximityDetectorView

struct ProximityDetectorView: View {
		@Environment(\.createDataHandler) private var createDataHandler
		@StateObject private var viewModel = ProximityDetectorViewModel()
		@State private var showModal = false
		@AppStorage("Push-Up") private var pushupDailyGoal: Int = 0
		@State private var flipAngle = Double.zero
		@State private var flipX = Double.zero

		@AppStorage("isHapticFeedbackEnabled") private var isHapticFeedbackEnabled = true
		@AppStorage("isVoiceFeedbackEnabled") private var isVoiceFeedbackEnabled = true
		@AppStorage("selectedVoiceType") private var selectedVoiceType = "en-US"
		@AppStorage("voiceSpeed") private var voiceSpeed: Double = 0.6

		let cornerRadius: CGFloat = 20

		var body: some View {
				let mainColor = Color.Neumorphic.main
				let secondaryColor = Color.Neumorphic.secondary
				ZStack {
						mainColor.edgesIgnoringSafeArea(.all)
						VStack {
								ZStack {
										ProgressView(value: Double(activityProgress), total: Double(pushupDailyGoal))
												.progressViewStyle(CustomCircular(strokeColor: activityProgress >= 1 ? mainColor : secondaryColor))
												.animation(.linear, value: activityProgress)
												.frame(width: 300, height: 300)
												.padding()

										HStack {
												Button(action: {
														viewModel.updateCount(0, 1, false)
												}) {
														Image(systemName: "minus.circle.fill")
																.font(.title)
																.frame(width: 6)
												}.softButtonStyle(Circle())

												Text("\(viewModel.objectCount)")
														.font(.system(size: 65, weight: .black, design: .monospaced))
														.rotation3DEffect(.degrees(flipX), axis: (x: 1, y: 0, z: 0))
														.animation(.default.delay(0), value: flipX)
														.padding()
														.frame(minWidth: 155)

												Button(action: {
														viewModel.updateCount(1, 0, false)
												}) {
														Image(systemName: "plus.circle.fill")
																.font(.title)
																.frame(width: 6)
												}.softButtonStyle(Circle())
										}
								}

								Text("Time: \(viewModel.formattedTime)")
										.font(.title2)
										.padding()

								Button(action: viewModel.toggleTimer) {
										Text(viewModel.isTimerRunning ? "Pause" : "Start").bold()
								}.softButtonStyle(RoundedRectangle(cornerRadius: cornerRadius))
										.padding()

								HStack {
										Button {
												viewModel.updateCount(0, 0, true)
												withAnimation(.bouncy) {
														flipX = (flipX == .zero) ? 360 : .zero
												}
										} label: {
												Text("Rest Count").bold()
										}.softButtonStyle(RoundedRectangle(cornerRadius: cornerRadius))
												.padding()

										Button(action: viewModel.resetTimer) {
												Text("Reset Timer").bold()
										}.softButtonStyle(RoundedRectangle(cornerRadius: cornerRadius))
												.padding()
								}

								MTSlide(
										isDisabled: !viewModel.isTimerRunning && viewModel.objectCount == 0,
										thumbnailTopBottomPadding: 3,
										thumbnailLeadingTrailingPadding: 3,
										text: "Save Workout",
										textColor: mainColor,
										thumbnailColor: mainColor,
										sliderBackgroundColor: secondaryColor,
										iconName: "plus",
										didReachEndAction: { slider in
												Task {
														if let dataHandler = await createDataHandler() {
																do {
																		try await viewModel.saveWorkout(dataHandler: dataHandler)
																		slider.resetState()
																} catch {
																		print("Error saving workout: \(error)")
																}
														}
												}
										}
								)
								.frame(height: 60)
								.padding()
						}

						.navigationBarItems(
								trailing:
								Button(action: {
										showModal.toggle()
								}) {
										Image(systemName: "gear")
								}
						)
						.sheet(isPresented: $showModal) {
								ProximitySettings()
						}.presentationDetents([.medium])
				}
				.onAppear {
						updateViewModelSettings()
						viewModel.startMonitoring()
				}
				.onDisappear {
						viewModel.stopMonitoring()
				}
				.onChange(of: isHapticFeedbackEnabled) { updateViewModelSettings() }
				.onChange(of: isVoiceFeedbackEnabled) { updateViewModelSettings() }
				.onChange(of: selectedVoiceType) { updateViewModelSettings() }
				.onChange(of: voiceSpeed) { updateViewModelSettings() }
		}

		private var activityProgress: CGFloat {
				CGFloat(viewModel.objectCount) / CGFloat(pushupDailyGoal)
		}

		private func updateViewModelSettings() {
				viewModel.updateSettings(
						isHapticFeedbackEnabled: isHapticFeedbackEnabled,
						isVoiceFeedbackEnabled: isVoiceFeedbackEnabled,
						selectedVoiceType: selectedVoiceType,
						voiceSpeed: voiceSpeed
				)
		}
}

// MARK: - ProximityDetectorViewModel

class ProximityDetectorViewModel: ObservableObject {
		@Published var proximityState = false
		@Published var objectCount = 0
		@Published var formattedTime = "00:00"
		@Published var isTimerRunning = false
		@Published var elapsedTime: TimeInterval = 0

		private var isHapticFeedbackEnabled = true
		private var isVoiceFeedbackEnabled = true
		private var selectedVoiceType = "en-US"
		private var voiceSpeed: Double = 0.6

		private let device = UIDevice.current
		private var timer: Timer?

		func updateSettings(
				isHapticFeedbackEnabled: Bool,
				isVoiceFeedbackEnabled: Bool,
				selectedVoiceType: String,
				voiceSpeed: Double
		) {
				self.isHapticFeedbackEnabled = isHapticFeedbackEnabled
				self.isVoiceFeedbackEnabled = isVoiceFeedbackEnabled
				self.selectedVoiceType = selectedVoiceType
				self.voiceSpeed = voiceSpeed
		}

		func startMonitoring() {
				device.isProximityMonitoringEnabled = true
				if device.isProximityMonitoringEnabled {
						NotificationCenter.default.addObserver(self,
						                                       selector: #selector(proximityChanged),
						                                       name: UIDevice.proximityStateDidChangeNotification,
						                                       object: device)
				}
		}

		func stopMonitoring() {
				device.isProximityMonitoringEnabled = false
				NotificationCenter.default.removeObserver(self)
				stopTimer()
		}

		func updateCount(_ increment: Int?, _ decrement: Int?, _ reset: Bool?) {
				DispatchQueue.main.async {
						var shouldAnnounce = false
						
						if let increment {
								self.objectCount += increment
								shouldAnnounce = true
						}
						
						if let decrement, self.objectCount - decrement >= 0 {
								self.objectCount -= decrement
								shouldAnnounce = true
						}
						
						if let reset, reset {
								self.objectCount = 0
								shouldAnnounce = true
						}
						
						if shouldAnnounce {
								self.announceCount()
						}
				}
		}

		func toggleTimer() {
				DispatchQueue.main.async {
						if self.isTimerRunning {
								self.stopTimer()
						} else {
								self.startTimer()
						}
				}
		}

		func resetTimer() {
				DispatchQueue.main.async {
						self.stopTimer()
						self.elapsedTime = 0
						self.updateFormattedTime()
				}
		}

		func saveWorkout(dataHandler: DataHandler) async throws {
				try await dataHandler.newWorkout(date: Date(), duration: elapsedTime, count: objectCount, type: "pushup")
				print("Workout saved successfully")
				await MainActor.run {
						self.resetTimer()
						self.updateCount(0, 0, true)
				}
		}

		// MARK: Private

		@objc private func proximityChanged(_: Notification) {
				DispatchQueue.main.async {
						self.proximityState = self.device.proximityState
						if self.proximityState {
								self.updateCount(1, nil, nil)
						}
				}
		}

		private func announceCount() {
				SpeechManager.shared.announceCount(
						objectCount,
						isHaptic: isHapticFeedbackEnabled,
						isVoiceEnabled: isVoiceFeedbackEnabled,
						voiceType: selectedVoiceType,
						voiceSpeed: voiceSpeed
				)
		}

		private func startTimer() {
				timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
						DispatchQueue.main.async {
								self?.elapsedTime += 1
								self?.updateFormattedTime()
						}
				}
				isTimerRunning = true
		}

		private func stopTimer() {
				timer?.invalidate()
				timer = nil
				isTimerRunning = false
		}

		private func updateFormattedTime() {
				let minutes = (Int(elapsedTime) % 3600) / 60
				let seconds = Int(elapsedTime) % 60
				formattedTime = String(format: "%02d:%02d", minutes, seconds)
		}
}

// MARK: - ProximitySettings

struct ProximitySettings: View {
		@AppStorage("Push-Up") var pushupDailyGoal: Int = 100

		var body: some View {
				Form {
						Section(header: Text("Settings")) {
								HStack {
										Text("Daily Goal")
										//					Spacer()
										Stepper("", value: $pushupDailyGoal, step: 1)
										TextField("Daily Goal: ", value: $pushupDailyGoal, formatter: NumberFormatter())
												.frame(width: 30)
								}
						}
				}
		}
}

// MARK: - ProximityDetectorView_Previews

struct ProximityDetectorView_Previews: PreviewProvider {
		static var previews: some View {
				ProximityDetectorView()
						.environment(\.colorScheme, .dark)
		}
}
