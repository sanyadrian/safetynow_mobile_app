import SwiftUI

enum SubScreen {
    case hazardTiles
    case industryTiles
    case talksList(filterType: TalkFilterType, filterValue: String)
    case talkDetail(talk: TalkModel, filterType: TalkFilterType, filterValue: String)
}

struct MainView: View {
    @State private var selectedTab: Tab = .home
    @State private var subScreen: SubScreen? = nil
    @AppStorage("selectedLanguage") var selectedLanguage: String = "en"

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                switch selectedTab {
                case .home:
                    DashboardView(selectedTab: $selectedTab)
                case .search:
                    if let subScreen = subScreen {
                        switch subScreen {
                        case .hazardTiles:
                             HazardTilesView(
                                onTalksTap: { value in
                                    self.subScreen = .talksList(filterType: .hazard, filterValue: value)
                                },
                                onBack: {
                                    self.subScreen = nil
                                }
                            )
                        case .industryTiles:
                            IndustryTilesView(
                                onTalksTap: { value in
                                    self.subScreen = .talksList(filterType: .industry, filterValue: value)
                                },
                                onBack: {
                                    self.subScreen = nil
                                }
                            )
                        case .talksList(let filterType, let filterValue):
                            TalksListView(
                                filterType: filterType,
                                filterValue: filterValue,
                                onTalkTap: { talk in
                                    self.subScreen = .talkDetail(talk: talk, filterType: filterType, filterValue: filterValue)
                                },
                                onBack: {
                                    switch filterType {
                                    case .hazard:
                                        self.subScreen = .hazardTiles
                                    case .industry:
                                        self.subScreen = .industryTiles
                                    }
                                }
                            )
                        case .talkDetail(let talk, let filterType, let filterValue):
                                    TalkDetailView(talk: talk, onBack: {
                                        self.subScreen = .talksList(filterType: filterType, filterValue: filterValue)
                                    })
                        }
                    } else {
                        FindTalkView(
                            selectedTab: $selectedTab,
                            onHazardTap: { self.subScreen = .hazardTiles },
                            onIndustryTap: { self.subScreen = .industryTiles }
                        )
                    }
                case .refresh:
                    HistoryView(selectedTab: $selectedTab)
                case .profile:
                    ProfileView(selectedTab: $selectedTab)
                }

                BottomNavBar(selectedTab: selectedTab) { tab in
                    selectedTab = tab
                    subScreen = nil // Reset subScreen when switching tabs
                }
            }
        }
        .id(selectedLanguage)
    }
}
