//  Created by Raidel Almeida on 6/30/24.
//
//  ElevationChangeView.swift
//  excallibur
//
//

import SwiftUI
import CoreMotion
import Combine
import AVFoundation
import SwiftData

class MotionManager: ObservableObject {
    @Published var squatCount = 0
    @Published var isTracking = false
    @Published var feedback = ""
    @Published var workoutDuration: TimeInterval = 0
    @Published var isCalibrated = false
    
    private let motionManager = CMMotionManager()
    private var accelerometerData = [FilteredAccelerometerData]()
    private var gyroData = [FilteredGyroData]()
    private var timer: AnyCancellable?
    private var workoutTimer: Timer?
    
    private var calibrationData: [Double] = []
    private var thresholds: (lower: Double, upper: Double) = (0, 0)
    
    private let synthesizer = AVSpeechSynthesizer()
    
    private var squatState: SquatState = .standing
    
    enum SquatState {
        case standing, goingDown, bottom, goingUp
    }
    
    func startTracking() {
        if !isCalibrated {
            feedback = "Please calibrate first"
            isTracking = false
            return
        }
        
        if motionManager.isAccelerometerAvailable && motionManager.isGyroAvailable {
            motionManager.accelerometerUpdateInterval = 1.0 / 50.0 // 50 Hz
            motionManager.gyroUpdateInterval = 1.0 / 50.0 // 50 Hz
            motionManager.startAccelerometerUpdates()
            motionManager.startGyroUpdates()
            feedback = "Tracking started"
            
            timer = Timer.publish(every: 1.0/50.0, on: .main, in: .default).autoconnect().sink { [weak self] _ in
                self?.processSensorData()
            }
            
            workoutTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.workoutDuration += 1
            }
        } else {
            feedback = "Sensor not available"
        }
        
        isTracking = true
    }
    
    func stopTracking() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
        timer?.cancel()
        timer = nil
        workoutTimer?.invalidate()
        workoutTimer = nil
        feedback = "Tracking stopped"
        isTracking = false
    }
    
    private func processSensorData() {
        guard let accelerometerData = motionManager.accelerometerData,
              let gyroData = motionManager.gyroData else { return }
        
        let filteredAccel = lowPassFilter(input: accelerometerData.acceleration)
        let filteredGyro = lowPassFilter(input: gyroData.rotationRate)
        
        detectSquat(accel: filteredAccel, gyro: filteredGyro)
    }
    
    private func lowPassFilter(input: CMAcceleration) -> CMAcceleration {
        let alpha = 0.1
        let filtered = CMAcceleration(
            x: input.x * alpha + (1 - alpha) * (accelerometerData.last?.acceleration.x ?? 0),
            y: input.y * alpha + (1 - alpha) * (accelerometerData.last?.acceleration.y ?? 0),
            z: input.z * alpha + (1 - alpha) * (accelerometerData.last?.acceleration.z ?? 0)
        )
        let filteredData = FilteredAccelerometerData(timestamp: Date().timeIntervalSince1970, acceleration: filtered)
        accelerometerData.append(filteredData)
        return filtered
    }
    
    private func lowPassFilter(input: CMRotationRate) -> CMRotationRate {
        let alpha = 0.1
        let filtered = CMRotationRate(
            x: input.x * alpha + (1 - alpha) * (gyroData.last?.rotationRate.x ?? 0),
            y: input.y * alpha + (1 - alpha) * (gyroData.last?.rotationRate.y ?? 0),
            z: input.z * alpha + (1 - alpha) * (gyroData.last?.rotationRate.z ?? 0)
        )
        let filteredData = FilteredGyroData(timestamp: Date().timeIntervalSince1970, rotationRate: filtered)
        gyroData.append(filteredData)
        return filtered
    }
    
    private func detectSquat(accel: CMAcceleration, gyro: CMRotationRate) {
        let accelMagnitude = sqrt(pow(accel.x, 2) + pow(accel.y, 2) + pow(accel.z, 2))
        let gyroMagnitude = sqrt(pow(gyro.x, 2) + pow(gyro.y, 2) + pow(gyro.z, 2))
        
        switch squatState {
            case .standing:
                if accelMagnitude < thresholds.lower && gyroMagnitude > 0.5 {
                    squatState = .goingDown
                    feedback = "Going down"
                }
            case .goingDown:
                if accelMagnitude < thresholds.lower - 0.1 {
                    squatState = .bottom
                    feedback = "At the bottom"
                }
            case .bottom:
                if accelMagnitude > thresholds.lower && gyroMagnitude > 0.5 {
                    squatState = .goingUp
                    feedback = "Going up"
                }
            case .goingUp:
                if accelMagnitude > thresholds.upper {
                    squatState = .standing
                    squatCount += 1
                    feedback = "Squat completed!"
                    provideHapticFeedback()
                    speakFeedback("Great job! Squat number \(squatCount) completed.")
                }
        }
    }
    
    func calibrate(squatData: [Double]) {
        calibrationData = squatData
        let mean = squatData.reduce(0, +) / Double(squatData.count)
        let stdDev = sqrt(squatData.map { pow($0 - mean, 2) }.reduce(0, +) / Double(squatData.count))
        
        thresholds.lower = mean - stdDev
        thresholds.upper = mean + stdDev
        
        isCalibrated = true
        feedback = "Calibration complete"
    }
    
    private func provideHapticFeedback() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    private func speakFeedback(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
    
//    func saveWorkoutData(modelContext: ModelContext) {
//        let workout = WorkoutData(date: Date(), duration: workoutDuration, squatCount: squatCount)
//        modelContext.insert(workout)
//        do {
//            try modelContext.save()
//        } catch {
//            print("Error saving workout data: \(error)")
//        }
//    }
    
}
    
//    func loadWorkoutData() -> [WorkoutData] {
//        guard let workoutsData = UserDefaults.standard.array(forKey: "workouts") as? [Data] else {
//            return []
//        }
//        
//        return workoutsData.compactMap { try? JSONDecoder().decode(WorkoutData.self, from: $0) }
//    }
//}
//extension UserDefaults {
//    func workoutData() -> [WorkoutData] {
//        guard let data = self.data(forKey: "workouts") else { return [] }
//        return (try? JSONDecoder().decode([WorkoutData].self, from: data)) ?? []
//    }
//    
//    func setWorkoutData(_ workouts: [WorkoutData]) {
//        let data = try? JSONEncoder().encode(workouts)
//        self.set(data, forKey: "workouts")
//    }
//}

//struct WorkoutData: Codable, Identifiable {
//    var id = UUID()
//    let date: Date
//    let duration: TimeInterval
//    let squatCount: Int
//}

struct FilteredAccelerometerData {
    var timestamp: TimeInterval
    var acceleration: CMAcceleration
}

struct FilteredGyroData {
    var timestamp: TimeInterval
    var rotationRate: CMRotationRate
}

struct ElevationChangeView: View {
    @StateObject private var motionManager = MotionManager()
    @State private var showCalibration = false
    @State private var showStats = false
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Squat Count: \(motionManager.squatCount)")
                    .font(.largeTitle)
                    .padding()
                
                Button(action: {
                    if motionManager.isTracking {
                        motionManager.stopTracking()
                    } else {
                        motionManager.startTracking()
                    }
                }) {
                    Text(motionManager.isTracking ? "Stop" : "Start")
                        .font(.title)
                        .padding()
                        .background(motionManager.isTracking ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Text(motionManager.feedback)
                    .font(.headline)
                    .padding()
                
                Button("Save Workout") {
                    saveWorkout()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(!motionManager.isTracking && motionManager.squatCount == 0)
            }
            .navigationBarTitle("Squat Tracker")
            .navigationBarItems(
                trailing: HStack {
                    Button(action: {
                        showCalibration = true
                    }) {
                        Image(systemName: "gear")
                    }
                    Button(action: {
                        showStats = true
                    }) {
                        Image(systemName: "chart.bar")
                    }
                }
            )
        }
        .sheet(isPresented: $showCalibration) {
            CalibrationView(calibrate: motionManager.calibrate)
        }
        .sheet(isPresented: $showStats) {
            StatsView()
        }
    }

    private func saveWorkout() {
        let workout = WorkoutData(date: Date(), duration: motionManager.workoutDuration, count: motionManager.squatCount, type: "squat")
        modelContext.insert(workout)
        do {
            try modelContext.save()
            print("Workout saved successfully")
        } catch {
            print("Failed to save workout: \(error)")
        }
        motionManager.stopTracking()
    }
}

struct CalibrationView: View {
    @State private var calibrationData: [Double] = []
    @State private var isCalibrating = false
    @State private var squatCount = 0
    var calibrate: ([Double]) -> Void
    
    let motionManager = CMMotionManager()
    
    var body: some View {
        VStack {
            Text("Calibration")
                .font(.title)
                .padding()
            
            Text("Perform 5 squats to calibrate")
                .padding()
            
            Text("Squats: \(squatCount)/5")
                .padding()
            
            Button(isCalibrating ? "Stop Calibration" : "Start Calibration") {
                isCalibrating.toggle()
                if isCalibrating {
                    startCalibration()
                } else {
                    stopCalibration()
                }
            }
            .padding()
            .background(isCalibrating ? Color.red : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
    
    private func startCalibration() {
        calibrationData.removeAll()
        squatCount = 0
        
        motionManager.accelerometerUpdateInterval = 1.0 / 50.0
        motionManager.startAccelerometerUpdates(to: .main) { data, _ in
            if let acceleration = data?.acceleration {
                let magnitude = sqrt(pow(acceleration.x, 2) + pow(acceleration.y, 2) + pow(acceleration.z, 2))
                calibrationData.append(magnitude)
                if calibrationData.count > 50 {
                    detectSquat()
                }
            }
        }
    }
    
    private func stopCalibration() {
        motionManager.stopAccelerometerUpdates()
        if squatCount == 5 {
            calibrate(calibrationData)
        }
    }
    
    private func detectSquat() {
        let recentData = Array(calibrationData.suffix(50))
        let mean = recentData.reduce(0, +) / Double(recentData.count)
        let stdDev = sqrt(recentData.map { pow($0 - mean, 2) }.reduce(0, +) / Double(recentData.count))
        
        if recentData.last! > mean + stdDev && squatCount < 5 {
            squatCount += 1
            if squatCount == 5 {
                stopCalibration()
            }
        }
    }
}


//preview
struct ElevationChangeView_Previews: PreviewProvider {
    static var previews: some View {
        if #available(iOS 17.0, *) {
            ElevationChangeView()
        } else {
                // Fallback on earlier versions
        }
    }
}
