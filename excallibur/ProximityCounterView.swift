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

struct ProximityDetectorView: View {
    @StateObject private var viewModel = ProximityDetectorViewModel()
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack {
            Text("Proximity: \(viewModel.proximityState ? "Near" : "Far")")
                .font(.title)
                .padding()
            Spacer()
            HStack {
                Button(action: {
                    viewModel.updateCount(0, 1, false)
                }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                }
                
                Text("Count: \(viewModel.objectCount)")
                    .font(.largeTitle)
                    .padding()
                
                Button(action: {
                    viewModel.updateCount(1, 0, false)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.yellow)
                }
            }
            
            Text("Time: \(viewModel.formattedTime)")
                .font(.title2)
                .padding()
            
            HStack {
                Button(action: {
                    viewModel.updateCount(0, 0, true)
                }) {
                    Text("Reset Count")
                }
                .padding()
                .background(.teal)
                .cornerRadius(10)
                
                Button(action: viewModel.toggleTimer) {
                    Text(viewModel.isTimerRunning ? "Pause" : "Start")
                }
//                .frame(minWidth: 0, maxWidth: 200)
                .padding()
                .background(.mint)
                .cornerRadius(10)
                
                Button(action: viewModel.resetTimer) {
                    Text("Reset Timer")
                }
                .padding()
                .background(.teal)
                .cornerRadius(10)
            }
            .padding()
            .foregroundColor(.white)
                
            Spacer()
            Button("Save Workout") {
                viewModel.saveWorkout()
            }
            .padding()
            .background(.cyan)
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
    
    private let device = UIDevice.current
    private let synthesizer = AVSpeechSynthesizer()
    private var timer: Timer?
    
    private let dataSource: WorkoutDataSource
    
    init(dataSource: WorkoutDataSource = .shared) {
        self.dataSource = dataSource
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

//    func resetCount() {
//        objectCount = 0
//        announceCount()
//    }
    
    func updateCount(_ increment: Int?, _ decrement: Int?, _ reset: Bool?) {
        if let increment = increment {
            objectCount += increment
//            announceCount()
        }
        
        if let decrement = decrement, objectCount - decrement >= 0 {
            objectCount -= decrement
//            announceCount()
        }
        
        if let reset = reset, reset {
            objectCount = 0
            announceCount()
        }
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
    
    @MainActor func saveWorkout() {
        let workout = WorkoutData(date: Date(), duration: elapsedTime, count: objectCount, type: "pushup")
        dataSource.addWorkout(workout)
        print("Workout saved successfully: \(workout)")
        stopMonitoring()
        resetTimer()
        updateCount(0, 0, true)
    }
    
    private func updateFormattedTime() {
        let hours = Int(elapsedTime) / 3600
        let minutes = (Int(elapsedTime) % 3600) / 60
        let seconds = Int(elapsedTime) % 60
        formattedTime = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

struct ProximityDetectorView_Previews: PreviewProvider {
    static var previews: some View {
        ProximityDetectorView()
    }
}
