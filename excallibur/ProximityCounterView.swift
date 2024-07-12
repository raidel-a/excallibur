//  Created by Raidel Almeida on 6/28/24.
//
//  ProximityCounterView.swift
//  excallibur
//
//

import SwiftUI
import AVFoundation
import UIKit

struct ProximityDetectorView: View {
    @EnvironmentObject var viewModel: ProximityDetectorViewModel
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack {
            Text("Proximity State: \(viewModel.proximityState ? "Near" : "Far")")
                .font(.title)
                .padding()
            
            Text("Push-up Count: \(viewModel.objectCount)")
                .font(.largeTitle)
                .padding()
            
            Text("Time: \(viewModel.formattedTime)")
                .font(.title2)
                .padding()
            
            HStack {
                Button(action: viewModel.resetCount) {
                    Text("Reset Count")
                }
                .padding()
                
                Button(action: viewModel.toggleTimer) {
                    Text(viewModel.isTimerRunning ? "Pause" : "Start")
                }
                .padding()
                
                Button(action: viewModel.resetTimer) {
                    Text("Reset Timer")
                }
                .padding()
            }
            Button("Save Workout") {
                saveWorkout()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(!viewModel.isTimerRunning && viewModel.objectCount == 0)
        }
        .navigationTitle("Push-up Tracker")
        .onAppear {
            viewModel.startMonitoring()
        }
        .onDisappear {
            viewModel.stopMonitoring()
        }
    }
    
    private func saveWorkout() {
        let workout = WorkoutData(date: Date(), duration: viewModel.elapsedTime, count: viewModel.objectCount, type: .pushup)
        modelContext.insert(workout)
        do {
            try modelContext.save()
            print("Workout saved successfully: \(workout)")
        } catch {
            print("Error saving workout: \(error)")
        }
        viewModel.stopMonitoring()
        viewModel.resetTimer()
        viewModel.resetCount()
    }
}






class ProximityDetectorViewModel: ObservableObject {
    @Published var proximityState = false
    @Published var objectCount = 0
    @Published var formattedTime = "00:00:00"
    @Published var isTimerRunning = false
    
    @Published var elapsedTime: TimeInterval = 0
    
    @AppStorage("isHapticFeedbackEnabled") private var isHapticFeedbackEnabled = true
    @AppStorage("isVoiceFeedbackEnabled") private var isVoiceFeedbackEnabled = true
    @AppStorage("selectedVoiceType") private var selectedVoiceType = "en-US"
    @AppStorage("voiceSpeed") private var voiceSpeed: Double = 0.6
    
    var availableVoiceTypes: [String] {
        AVSpeechSynthesisVoice.speechVoices().compactMap { $0.language }
    }
    
    private let device = UIDevice.current
    private let synthesizer = AVSpeechSynthesizer()
    private var timer: Timer?
//    private var elapsedTime: TimeInterval = 0
    
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
    
    @objc private func proximityChanged(_ notification: Notification) {
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

    
    func resetCount() {
        objectCount = 0
        announceCount()
    }
    
    func toggleTimer() {
        if isTimerRunning {
            stopTimer()
        } else {
            startTimer()
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
    
    func resetTimer() {
        stopTimer()
        elapsedTime = 0
        updateFormattedTime()
    }
    
    private func updateFormattedTime() {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
        formattedTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
