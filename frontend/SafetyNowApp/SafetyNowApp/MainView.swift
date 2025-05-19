import SwiftUI

struct MainView: View {
    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                DashboardView(selectedTab: $selectedTab)
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .tag(Tab.home)

            NavigationStack {
                FindTalkView(selectedTab: $selectedTab)
            }
            .tabItem {
                Label("Find a Talk", systemImage: "magnifyingglass")
            }
            .tag(Tab.search)

            NavigationStack {
                HistoryView(selectedTab: $selectedTab)
            }
            .tabItem {
                Label("History", systemImage: "clock.arrow.circlepath")
            }
            .tag(Tab.refresh)

            NavigationStack {
                ProfileView(selectedTab: $selectedTab)
            }
            .tabItem {
                Label("Profile", systemImage: "person")
            }
            .tag(Tab.profile)
        }
    }
}
