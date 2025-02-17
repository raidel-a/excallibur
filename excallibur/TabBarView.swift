//
//  TabBarView.swift
//

import SwiftUI

struct TabBarView: View {
		
		@State var selectedTab = 0
		var body: some View {
				ZStack(alignment: .bottom){
						TabView(selection: $selectedTab) {
								
								ExerciseSelectionView()
										.tag(0)
								
								StatsView()
										.tag(1)
								
								SettingsView()
										.tag(2)
								
						}
						HStack(alignment: .center) {
								ForEach((TabItems.allCases), id: \.self){ item in
										HStack(alignment: .center) {
												Spacer()
												TabItemView(item: item, selected: $selectedTab)
												Spacer()
										}.frame(width:  80)
								}
						}.frame(maxWidth: .infinity, maxHeight: 70)
								.padding(.horizontal, 26)
								.padding(.bottom, -14)
				}
		}
}

enum TabItems: Int, CaseIterable{
		case home = 0
		case stats
		case settings
	
		
		var title: String{
				switch self {
						case .home:
								return "Trackers"
						case .stats:
								return "Stats"
						case .settings:
								return "Profile"

				}
		}
		
		var iconName: String{
				switch self {
						case .home:
								return "figure.mixed.cardio"
						case .stats:
								return "chart.bar.fill"
						case .settings:
								return "person.fill"
				}
		}
}

struct TabItemView: View {
		var item: TabItems
		@Binding var selected: Int
		
		let mainColor = Color.Neumorphic.main
		let secondaryColor = Color.Neumorphic.secondary

		
		var body: some View {
				VStack {
						Button{
								selected = item.rawValue
						} label: {
								VStack(spacing: 10){
										if selected == item.rawValue {
												Color(Color.accentColor).frame(width: 70, height: 2)
														.padding(.top, 1)
										} else {
												Spacer().frame(width: 70, height: 2)
														.padding(.top, 1)
										}
										
										Image(systemName: item.iconName)
												.resizable()
												.renderingMode(.template)
												.foregroundStyle(selected == item.rawValue ? secondaryColor : .gray.opacity(0.5))
												.frame(width: 20, height: 20)
										Text(item.title)
												.font(.system(size: 11))
												.foregroundStyle(selected == item.rawValue ? secondaryColor : .gray.opacity(0.5))
								}
								Spacer()
						}
				}.frame(width: 80)
		}
}

