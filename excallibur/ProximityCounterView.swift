//  Created by Raidel Almeida on 6/28/24.
//
//  ProximityCounterView.swift
//  excallibur
//
//

import AVFoundation
import Combine
import SwiftUI
import UIKit

// MARK: - ProximityDetectorView

struct ProximityDetectorView: View {
	// MARK: Internal

	let cornerRadius: CGFloat = 15

	var body: some View {
		let mainColor = Color.Neumorphic.main
		let secondaryColor = Color.Neumorphic.secondary
		ZStack {
			mainColor.edgesIgnoringSafeArea(.all)
			VStack {
				Text("Proximity: \(viewModel.proximityState ? "Near" : "Far")")
					.font(.title)
					.padding()
				Spacer()

				ZStack {
					ActivityProgressView(
						color: activityProgress == 1 ? mainColor : secondaryColor,
						progress: activityProgress,
						width: 30
					)
					.frame(width: 300, height: 300)
					.padding()

					HStack {
						Button(action: {
							viewModel.updateCount(0, 1, false)
						}) {
							Image(systemName: "minus.circle.fill")
								.font(.largeTitle)
								.foregroundColor(.orange)
						}

						Text("\(viewModel.objectCount)")
							.font(.custom("Avenir Next", size: 100))
							.fontWeight(.bold)
							.rotation3DEffect(.degrees(flipX), axis: (x: 1, y: 0, z: 0))
							.animation(.default.delay(0), value: flipX)
							.padding()

						Button(action: {
							viewModel.updateCount(1, 0, false)
						}) {
							Image(systemName: "plus.circle.fill")
								.font(.largeTitle)
								.foregroundColor(.yellow)
						}
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
					thumbnailTopBottomPadding: 5,
					thumbnailLeadingTrailingPadding: 5,
					text: "Save Workout",
					textColor: mainColor,
					thumbnailColor: mainColor,
					sliderBackgroundColor: secondaryColor,
					iconName: "plus",
					didReachEndAction: { slider in
						viewModel.saveWorkout()
						slider.resetState()
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
				VStack {
					Text("Hello, I'm a modal!")
					Button("Dismiss") {
						showModal = false
					}
				}.presentationDetents([.medium])
			}

			.onAppear {
				viewModel.startMonitoring()
			}
			.onDisappear {
				viewModel.stopMonitoring()
			}
		}
	}

	// MARK: Private

	@State private var showModal = false

	@State private var activityProgress: CGFloat = 0.5

	@State private var flipAngle = Double.zero

	@State private var flipX = Double.zero

	@StateObject private var viewModel = ProximityDetectorViewModel()
	@Environment(\.modelContext) private var modelContext
}

// MARK: - ProximityDetectorViewModel

class ProximityDetectorViewModel: ObservableObject {
	// MARK: Lifecycle

	init(dataSource: WorkoutDataSource = .shared) {
		self.dataSource = dataSource
	}

	// MARK: Internal

	@Published var proximityState = false
	@Published var objectCount = 0
	@Published var formattedTime = "00:00"
	@Published var isTimerRunning = false
	@Published var elapsedTime: TimeInterval = 0

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
		if let increment {
			objectCount += increment
			//            announceCount()
		}

		if let decrement, objectCount - decrement >= 0 {
			objectCount -= decrement
			//            announceCount()
		}

		if let reset, reset {
			objectCount = 0
			//            announceCount()
		}
	}

	func toggleTimer() {
		if isTimerRunning {
			stopTimer()
		} else {
			startTimer()
		}
	}

	func resetTimer() {
		stopTimer()
		elapsedTime = 0
		updateFormattedTime()
	}

	@MainActor func saveWorkout() {
		let workout = WorkoutData(date: Date(), duration: elapsedTime, count: objectCount, type: "pushup")
		dataSource.addWorkout(workout)
		print("Workout saved successfully: \(workout)")
		stopMonitoring()
		resetTimer()
		updateCount(0, 0, true)
	}

	// MARK: Private

	@AppStorage("isHapticFeedbackEnabled") private var isHapticFeedbackEnabled = true
	@AppStorage("isVoiceFeedbackEnabled") private var isVoiceFeedbackEnabled = true
	@AppStorage("selectedVoiceType") private var selectedVoiceType = "en-US"
	@AppStorage("voiceSpeed") private var voiceSpeed: Double = 0.6

	private let device = UIDevice.current
	private let synthesizer = AVSpeechSynthesizer()
	private var timer: Timer?

	private let dataSource: WorkoutDataSource

	@objc private func proximityChanged(_: Notification) {
		DispatchQueue.main.async {
			self.proximityState = self.device.proximityState
			if self.proximityState {
				self.objectCount += 1
				self.announceCount()
			}
		}
	}

	private func announceCount() {
		if isHapticFeedbackEnabled {
			let impact = UIImpactFeedbackGenerator(style: .medium)
			impact.impactOccurred()
		}

		if isVoiceFeedbackEnabled {
			let ssml = """
			<speak>
			   \(objectCount)
			</speak>
			"""

			let utterance = AVSpeechUtterance(ssmlRepresentation: ssml)
			utterance!.voice = AVSpeechSynthesisVoice(language: selectedVoiceType)
			utterance!.rate = Float(voiceSpeed)

			synthesizer.speak(utterance!)
		}
	}

	private func startTimer() {
		timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
			self?.elapsedTime += 1
			self?.updateFormattedTime()
		}
		isTimerRunning = true
	}

	private func stopTimer() {
		timer?.invalidate()
		timer = nil
		isTimerRunning = false
	}

	private func updateFormattedTime() {
		let hours = Int(elapsedTime) / 3600
		let minutes = (Int(elapsedTime) % 3600) / 60
		let seconds = Int(elapsedTime) % 60
		formattedTime = String(format: "%02d:%02d", minutes, seconds)
	}
}

// MARK: - ProximityDetectorView_Previews

struct ProximityDetectorView_Previews: PreviewProvider {
	static var previews: some View {
		ProximityDetectorView()
			.environment(\.colorScheme, .dark)
	}
}
