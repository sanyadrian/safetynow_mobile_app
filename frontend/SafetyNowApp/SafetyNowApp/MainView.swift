import SwiftUI

struct MainView: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
        VStack(spacing: 0) {
            switch selectedTab {
            case .home:
                DashboardView(selectedTab: $selectedTab)
            case .search:
                FindTalkView(selectedTab: $selectedTab)
            case .refresh:
                Text("Refresh Page")
            case .profile:
                Text("Profile Page")
            }

            BottomNavBar(selectedTab: selectedTab) { tab in
                selectedTab = tab
            }
        }
    }
}
