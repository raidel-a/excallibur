//
//  CircularProg.swift
//

import SwiftUI

// MARK: - NeuView

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
			NeuView()
				.environment(\.colorScheme, .light)

			NeuView()
				.environment(\.colorScheme, .dark)
		}
	}
}
