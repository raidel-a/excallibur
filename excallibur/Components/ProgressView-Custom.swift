//
//  ProgressView-Custom.swift
//
import SwiftUI

struct CustomCircular: ProgressViewStyle {
	var strokeColor: Color
	var strokeWidth: CGFloat = 25.0

	func makeBody(configuration: Configuration) -> some View {
		let fractionCompleted = configuration.fractionCompleted ?? 0

		return ZStack {
			Circle()
				.stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
				.softOuterShadow(radius: 1)
			Circle()
				.trim(from: 0, to: fractionCompleted)
				.stroke(strokeColor
					.shadow(.inner(color: .black.opacity(0.5), radius: 2, x: 5, y: 0))
					.shadow(.inner(color: .black.opacity(0.2), radius: 5, x: 50, y: 10))
					.shadow(.inner(color: .black.opacity(0.5), radius: 2, x: -10, y: -5)),
					//					.shadow(.inner(color: .black.opacity(0.5), radius: 3, x: 5, y: -5))
					style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
				.rotationEffect(.degrees(-88))
		}
	}
}
