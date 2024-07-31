//
//  MTSlideToOpen-SwiftUI.swift
//  MTSlideToOpen-SwiftUI
//
//  Created by Le Manh Tien on 6/8/19.
//  Copyright © 2019 io.tienle. All rights reserved.
//

//
//  Slider.swift
//  excallibur
//
//  Created by Raidel Almeida on 7/22/24.
//

import SwiftUI

struct MTSlide: View {
	// MARK: Internal

	// Public Property
	var isDisabled: Bool = false
	var sliderTopBottomPadding: CGFloat = 0
	var thumbnailTopBottomPadding: CGFloat = 0
	var thumbnailLeadingTrailingPadding: CGFloat = 0
	var textLabelLeadingPadding: CGFloat = 0
	var text: String = "Slide"
	var textFont: Font = .system(size: 15)
	var textColor = Color(.sRGB, red: 25.0 / 255, green: 155.0 / 255, blue: 215.0 / 255, opacity: 0.7)
	var thumbnailColor = Color(.sRGB, red: 25.0 / 255, green: 155.0 / 255, blue: 215.0 / 255, opacity: 1)
	var thumbnailBackgroundColor: Color = .clear
	var sliderBackgroundColor = Color(.sRGB, red: 0.1, green: 0.64, blue: 0.84, opacity: 0.1)
	var resetAnimation: Animation = .easeIn(duration: 0.3)
	var iconName = ""
	var iconColor: Color = .white
	var didReachEndAction: ((MTSlide) -> Void)?

	var body: some View {
		GeometryReader { geometry in
			setupView(geometry: geometry)
		}
	}

	// MARK: Public Function

	func resetState(_: Bool = true) {
		draggableState = .ready
	}

	// MARK: Private

	private enum DraggableState {
		case ready
		case dragging(offsetX: CGFloat, maxX: CGFloat)
		case end(offsetX: CGFloat)

		// MARK: Internal

		var reachEnd: Bool {
			switch self {
			case .ready, .dragging:
				false
			case .end:
				true
			}
		}

		var isReady: Bool {
			switch self {
			case .dragging(_), .end:
				false
			case .ready:
				true
			}
		}

		var offsetX: CGFloat {
			switch self {
			case .ready:
				0.0
			case let .dragging((offsetX, _)):
				offsetX
			case let .end(offsetX):
				offsetX
			}
		}

		var textColorOpacity: Double {
			switch self {
			case .ready:
				1.0
			case .dragging(let (offsetX, maxX)):
				1.0 - Double(offsetX / maxX)
			case .end:
				0.0
			}
		}
	}

	// Private Property
	@State private var draggableState: DraggableState = .ready

	private func setupView(geometry: GeometryProxy) -> some View {
		let frame = geometry.frame(in: .global)
		let width = frame.size.width
		let height = frame.size.height
		let drag = DragGesture()
			.onChanged { drag in
				let maxX = width - height - thumbnailLeadingTrailingPadding * 2 + thumbnailTopBottomPadding * 2
				let currentX = drag.translation.width
				if currentX >= maxX {
					draggableState = .end(offsetX: maxX)
					didReachEndAction?(self)
				} else if currentX <= 0 {
					draggableState = .dragging(offsetX: 0, maxX: maxX)
				} else {
					draggableState = .dragging(offsetX: currentX, maxX: maxX)
				}
			}
			.onEnded(onDragEnded)
		let sliderCornerRadius = (height - sliderTopBottomPadding * 2) / 2
		return HStack {
			ZStack(alignment: .leading, content: {
				HStack {
					Text(text)
						.frame(maxWidth: .infinity)
						.padding([.leading], textLabelLeadingPadding)
						.foregroundColor(isDisabled ? .gray : .white)
						.opacity(draggableState.textColorOpacity)
						.animation(draggableState.isReady ? resetAnimation : nil, value: draggableState.textColorOpacity)
				}
				.frame(maxWidth: .infinity, maxHeight: .infinity)
//				.background(sliderBackgroundColor)
				.softInnerShadow(RoundedRectangle(cornerRadius: sliderCornerRadius))
				.cornerRadius(sliderCornerRadius)
				.padding([.top, .bottom], sliderTopBottomPadding)
				.softOuterShadow()

				Image(systemName: iconName)
					.foregroundColor(isDisabled ? .gray : iconColor)
					.font(.title.weight(.black))
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.aspectRatio(1.0, contentMode: .fit)
					.background(
						isDisabled ? thumbnailBackgroundColor :
							.gray.opacity(0.3))
					.clipShape(Circle())
					.softOuterShadow(offset: 5)
					.softInnerShadow(Circle(), spread: 0.1)
					.padding([.top, .bottom], thumbnailTopBottomPadding)
					.padding([.leading, .trailing], thumbnailLeadingTrailingPadding)
					.background(thumbnailBackgroundColor)
					.offset(x: draggableState.offsetX)
					.animation(draggableState.isReady ? resetAnimation : nil, value: draggableState.offsetX)
					.gesture(draggableState.reachEnd || isDisabled ? nil : drag)
			})
		}
		.disabled(isDisabled)
//		.opacity(isDisabled ? 0.5 : 1.0)
	}

	private func onDragEnded(drag _: DragGesture.Value) {
		switch draggableState {
		case .end(_), .dragging:
			draggableState = .ready
		case .ready:
			break
		}
	}
}
