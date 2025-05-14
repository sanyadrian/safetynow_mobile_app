import SwiftUI

enum Tab: String {
    case home
    case search
    case refresh
    case profile
}

struct BottomNavBar: View {
    var selectedTab: Tab
    var onTabSelected: (Tab) -> Void

    var body: some View {
        HStack {
            tabItem(icon: "house", selectedIcon: "house.fill", tab: .home)
            Spacer()
            tabItem(icon: "magnifyingglass", selectedIcon: "magnifyingglass.circle.fill", tab: .search)
            Spacer()
            tabItem(icon: "arrow.clockwise", selectedIcon: "arrow.clockwise.circle.fill", tab: .refresh)
            Spacer()
            tabItem(icon: "person.crop.circle", selectedIcon: "person.crop.circle.fill", tab: .profile)
        }
        .padding()
        .background(Color.white)
        .shadow(radius: 2)
    }

    @ViewBuilder
    private func tabItem(icon: String, selectedIcon: String, tab: Tab) -> some View {
        let isSelected = tab == selectedTab
        Image(systemName: isSelected ? selectedIcon : icon)
            .foregroundColor(isSelected ? .blue : .gray)
            .onTapGesture {
                onTabSelected(tab)
            }
    }
}
