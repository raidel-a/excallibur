//
//  CircularProg.swift
//  excallibur
//
//  Created by Raidel Almeida on 7/23/24.
//

import SwiftUI

// MARK: - CircularProgressBar

struct CircularProgressBar: View {
	// MARK: Internal

	var body: some View {
		VStack(spacing: 30) {
			ActivityProgressView(color: activityProgress >= 1 ? .green : .red, progress: activityProgress, width: Int(widthProgress))
				.frame(width: 300, height: 300)

			SliderView(progress: $activityProgress, title: "Move Progress")
				.padding()

			Button("Reset", action: { activityProgress = 0.0 })
				.buttonStyle(.borderedProminent)
		}
	}

	// MARK: Private

	@State private var activityProgress: CGFloat = 1.0
	@State private var widthProgress: CGFloat = 30.0
}

// MARK: - ActivityProgressView

struct ActivityProgressView: View {
	let color: Color
	let progress: CGFloat
	let width: Int

	let mainColor = Color.Neumorphic.main
	let secondaryColor = Color.Neumorphic.secondary

	var body: some View {
			ZStack {
				
			Circle()
				.stroke(lineWidth: (progress * CGFloat((width - 5))) + 10)
				.opacity(0.1)
				.foregroundStyle(secondaryColor)

			Circle()
				.trim(from: 0.0, to: progress)
				.stroke(style: StrokeStyle(lineWidth: CGFloat(width), lineCap: .round))
				.foregroundStyle(color
					.shadow(.inner(color: .black.opacity(0.5), radius: 2, x: 5, y: 0))
					.shadow(.inner(color: .black.opacity(0.5), radius: 5, x: 50, y: 10))
					.shadow(.inner(color: .black.opacity(0.5), radius: 2, x: -10, y: -5))
//					.shadow(.inner(color: .black.opacity(0.5), radius: 3, x: 5, y: -5))
				)
				.rotationEffect(Angle(degrees: 270.0))
				.animation(.smooth, value: progress)
		}
	}
}

// MARK: - SliderView

struct SliderView: View {
	@Binding var progress: CGFloat
	let title: String

	var body: some View {
		VStack {
			Text(title)
				.frame(maxWidth: .infinity, alignment: .leading)
			Slider(value: $progress, in: 0 ... 1.0, minimumValueLabel: Text("0"), maximumValueLabel: Text("100%")) {}
		}
	}
}

// MARK: - NeuView

// #Preview {
//	CircularProgressBar()
//
// }

struct NeuView: View {
	var body: some View {
		let cornerRadius: CGFloat = 15
		let mainColor = Color.Neumorphic.main
		let secondaryColor = Color.Neumorphic.secondary

		return ZStack {
			mainColor.edgesIgnoringSafeArea(.all)
			VStack(alignment: .center, spacing: 30) {
				Text("Neumorphic Soft UI").font(.headline).foregroundColor(secondaryColor)
				
				
				// Create simple shapes with soft inner shadow
				HStack(spacing: 40) {
					RoundedRectangle(cornerRadius: cornerRadius).fill(mainColor).frame(width: 150, height: 150)
						.softInnerShadow(RoundedRectangle(cornerRadius: cornerRadius))

					Circle().fill(mainColor).frame(width: 150, height: 150)
						.softInnerShadow(Circle())
				}
				
				
				// You can customize shadow by changing its color, spread, and shadow radius.
				HStack(spacing: 40) {
					ZStack {
						Circle().fill(mainColor)
							.softInnerShadow(Circle(), spread: 0.6)

						Circle().fill(mainColor).frame(width: 80, height: 80)
							.softOuterShadow(offset: 8, radius: 8)
					}.frame(width: 150, height: 150)

					ZStack {
						Circle().fill(mainColor)
							.softOuterShadow()

						Circle().fill(mainColor).frame(width: 80, height: 80)
							.softInnerShadow(Circle(), radius: 5)
					}.frame(width: 150, height: 150)
				}
				
				
// MARK: - Rectangles
				
				// Rectanlges with soft outer shadow
				HStack(spacing: 30) {
					RoundedRectangle(cornerRadius: cornerRadius).fill(mainColor).frame(width: 90, height: 90)
						.softOuterShadow()

					RoundedRectangle(cornerRadius: cornerRadius).fill(mainColor).frame(width: 90, height: 90)
						.softInnerShadow(RoundedRectangle(cornerRadius: cornerRadius))
				}
				
				
// MARK: - Buttons
				
				// You can simply create soft button with softButtonStyle method.
				Button(action: {}) {
					Text("Soft Button").fontWeight(.bold)
				}.softButtonStyle(RoundedRectangle(cornerRadius: cornerRadius))

				HStack(spacing: 20) {
					// Circle Button
					Button(action: {}) {
						Image(systemName: "heart.fill")
					}.softButtonStyle(Circle())

					// Circle Button
					Button(action: {}) {
						Image(systemName: "heart.fill")
					}.softButtonStyle(Circle(), mainColor: Color.red, textColor: Color.white, darkShadowColor: Color("redButtonDarkShadow"), lightShadowColor: Color("redButtonLightShadow"))
				}
			}
		}
	}
}

// MARK: - ContentView_Previews

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		Group {
//			CircularProgressBar()

			NeuView()
				.environment(\.colorScheme, .light)

			NeuView()
				.environment(\.colorScheme, .dark)
		}
	}
}
