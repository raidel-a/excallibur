//
//  TrackerSelectionView.swift
//

import SwiftData
import SwiftUI

struct ExerciseSelectionView: View {
		@State private var selectedExercise: Exercise?

		var body: some View {
				NavigationView {
						ScrollView(.vertical, showsIndicators: false) {
								LazyVGrid(columns: gridLayout, spacing: 20) {
										ForEach(exercises) { exercise in
												NavigationLink(
														destination: destinationView(for: exercise),
														tag: exercise,
														selection: $selectedExercise
												) {
														ItemView(exercise: exercise, selectedExercise: $selectedExercise)
												}
										}
								}
								.padding(20)
						}
						.background(Color.Neumorphic.main.ignoresSafeArea(.all, edges: .all))
						.navigationTitle("Exercises")
				}
		}

		@ViewBuilder
		func destinationView(for exercise: Exercise) -> some View {
				switch exercise.id {
						case 0:
								ProximityDetectorView()
						case 1:
								ElevationChangeView()
						case 2:
								SettingsView()
						default:
								Text("Unknown exercise")
				}
		}
}

struct ItemView: View {
		let exercise: Exercise
		@Binding var selectedExercise: Exercise?

		var body: some View {
				Button(action: {
						selectedExercise = exercise
				}) {
						VStack(alignment: .center, spacing: 6) {
										// Icon
										ZStack {
														Image(exercise.icon)
																		.resizable()
																		.scaledToFit()
																		.padding(15)
																		.frame(width: 110, height: 100)
																		.rotationEffect(exercise.icon == "figure.pushup" ? .degrees(75) : .degrees(0)) // temp fix for pushup icon
																		.offset(
																				x: exercise.icon == "figure.pushup" ? -4 : 0,
																				y: exercise.icon == "figure.pushup" ? 5 : 0
																		)
																		.offset(x: exercise.icon == "figure.squat" ? 3 : 0, y: exercise.icon == "figure.squat" ? 7 : 0)
										}
												.foregroundStyle(Color(Color.Neumorphic.main))
												.background(Color(red: exercise.red, green: exercise.green, blue: exercise.blue))
												.cornerRadius(16)
												.shadow(color: .accentColor, radius: 0.5)
												.softOuterShadow()

										Spacer(minLength: 1)
										// Name
										Text(exercise.name)
												.font(.title3)
												.fontWeight(.semibold)
												.shadow(color: .accentColor, radius: 0.8)
										
								}
						.padding(.all,3)
				}
				.softButtonStyle(RoundedRectangle(cornerRadius: 12))
		}
}

struct Exercise: Codable, Identifiable, Hashable {
		var id: Int
		var name: String
		var icon: String
		var color: [Double]

		var red: Double { color[0] }
		var green: Double { color[1] }
		var blue: Double { color[2] }

		// This property won't be encoded/decoded
		var destinationView: AnyView?

		enum CodingKeys: String, CodingKey {
				case id, name, icon, color
		}

		// Implement Hashable
		func hash(into hasher: inout Hasher) {
				hasher.combine(id)
				hasher.combine(name)
		}

		static func == (lhs: Exercise, rhs: Exercise) -> Bool {
				lhs.id == rhs.id && lhs.name == rhs.name
		}
}

let exercises = [
		Exercise(id: 0, name: "Push-ups", icon: "figure.pushup", color: [0.6, 0.3, 0.3], destinationView: AnyView(ProximityDetectorView())),
		Exercise(id: 1, name: "Squats", icon: "figure.squat", color: [0.3, 0.6, 0.3], destinationView: AnyView(ElevationChangeView())),
		Exercise(id: 2, name: "Jump Rope", icon: "figure.jumprope", color: [0.3, 0.3, 0.6], destinationView: AnyView(SettingsView())),
]

let gridLayout = [
		GridItem(.flexible()),
		GridItem(.flexible()),
]

struct ExerciseSelectionView_Previews: PreviewProvider {
		static var previews: some View {
				ExerciseSelectionView()
						.preferredColorScheme(.dark)
				ExerciseSelectionView()
						.preferredColorScheme(.light)
		}
}
