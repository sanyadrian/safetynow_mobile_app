import SwiftUI

struct FindTalkView: View {
    let categories: [(key: String, icon: String)] = [
        ("hazards", "pencil"),
        ("industry", "pencil"),
        ("send_talk", "calendar"),
        ("translate", "globe"),
        ("tools", "lightbulb"),
        ("calendar", "doc.on.doc")
    ]

    @Environment(\.dismiss) var dismiss
    @Binding var selectedTab: Tab
    let onHazardTap: () -> Void
    let onIndustryTap: () -> Void
    @State private var showUpgrade = false
    @State private var showCalendar = false
    @State private var showTranslate = false
    @State private var showShareTalkInfo = false
    @State private var showTools = false
    @State private var searchText: String = ""
    @State private var showSuggestions: Bool = false
    @State private var suggestions: [DashboardView.SearchSuggestion] = []
    @State private var navigateToSearchResults = false
    @State private var searchResults: [DashboardView.SearchSuggestion] = []
    @State private var selectedTalk: TalkModel? = nil
    @State private var selectedTool: Tool? = nil

    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(alignment: .center, spacing: 48) {
                        Text(LocalizationManager.shared.localizedString(for: "findtalk.explore"))
                            .font(.system(size: 48, weight: .bold))
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                        // --- SEARCH BAR ---
                        VStack(spacing: 0) {
                            HStack {
                                HStack {
                                    TextField("Search talks or tools...", text: $searchText, onEditingChanged: { editing in
                                        showSuggestions = editing && !searchText.isEmpty
                                    }, onCommit: {
                                        performSearch()
                                    })
                                    .padding(.vertical, 10)
                                    .padding(.leading, 12)
                                    .foregroundColor(.primary)
                                    .accentColor(.blue)
                                    .onChange(of: searchText) { newValue in
                                        if !newValue.isEmpty {
                                            fetchSuggestions(for: newValue)
                                            showSuggestions = true
                                        } else {
                                            suggestions = []
                                            showSuggestions = false
                                        }
                                    }
                                    Button(action: {
                                        performSearch()
                                    }) {
                                        Image(systemName: "magnifyingglass")
                                            .foregroundColor(.blue)
                                    }
                                    .padding(.trailing, 12)
                                }
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                        // --- END SEARCH BAR ---
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                            ForEach(categories, id: \.key) { category in
                                let title = LocalizationManager.shared.localizedString(for: "findtalk.\(category.key)")
                                let desc = LocalizationManager.shared.localizedString(for: "findtalk.\(category.key)_desc")
                                if category.key == "hazards" {
                                    Button(action: onHazardTap) {
                                        tileView(title: title, desc: desc, icon: category.icon)
                                    }
                                } else if category.key == "industry" {
                                    Button(action: onIndustryTap) {
                                        tileView(title: title, desc: desc, icon: category.icon)
                                    }
                                } else if category.key == "calendar" {
                                    Button(action: { showCalendar = true }) {
                                        tileView(title: title, desc: desc, icon: category.icon)
                                    }
                                } else if category.key == "translate" {
                                    Button(action: { showTranslate = true }) {
                                        tileView(title: title, desc: desc, icon: category.icon)
                                    }
                                } else if category.key == "send_talk" {
                                    Button(action: { showShareTalkInfo = true }) {
                                        tileView(title: title, desc: desc, icon: category.icon)
                                    }
                                } else if category.key == "tools" {
                                    Button(action: { showTools = true }) {
                                        tileView(title: title, desc: desc, icon: category.icon)
                                    }
                                } else {
                                    tileView(title: title, desc: desc, icon: category.icon)
                                }
                            }
                        }
                        Spacer()
                        NavigationLink(destination: UpgradePlanView(), isActive: $showUpgrade) { EmptyView() }
                        NavigationLink(destination: CalendarView(), isActive: $showCalendar) { EmptyView() }
                        NavigationLink(destination: LanguageSelectionView(), isActive: $showTranslate) { EmptyView() }
                        NavigationLink(destination: ShareTalkInfoView(), isActive: $showShareTalkInfo) { EmptyView() }
                        NavigationLink(destination: ToolsView(), isActive: $showTools) { EmptyView() }
                        NavigationLink(destination: selectedTalk.map { TalkDetailView(talk: $0) }, isActive: Binding(get: { selectedTalk != nil }, set: { if !$0 { selectedTalk = nil } })) { EmptyView() }
                        NavigationLink(destination: selectedTool.map { ToolDetailView(tool: $0) }, isActive: Binding(get: { selectedTool != nil }, set: { if !$0 { selectedTool = nil } })) { EmptyView() }
                        NavigationLink(destination: SearchResultsView(results: searchResults, query: searchText, onTalkTap: { talk in selectedTalk = talk }, onToolTap: { tool in selectedTool = tool }), isActive: $navigateToSearchResults) { EmptyView() }
                        HStack {
                            Spacer()
                            Button(action: { showUpgrade = true }) {
                                Text(LocalizationManager.shared.localizedString(for: "button.access_more"))
                                    .font(.footnote)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.blue)
                                    .cornerRadius(20)
                            }
                            .padding(.trailing, 32)
                            .padding(.bottom, 24)
                        }
                    }
                    .padding(.vertical, 60)
                }
                // Suggestions dropdown overlay
                if showSuggestions && !suggestions.isEmpty {
                    VStack {
                        Spacer().frame(height: 250) // Adjusted for iPad search bar height
                        List(suggestions, id: \ .id) { suggestion in
                            Button(action: {
                                showSuggestions = false
                                switch suggestion {
                                case .talk(let talk):
                                    selectedTalk = talk
                                case .tool(let toolTitle):
                                    fetchToolDetail(for: toolTitle)
                                }
                            }) {
                                HStack {
                                    Image(systemName: suggestionIcon(for: suggestion))
                                        .foregroundColor(.blue)
                                    Text(suggestion.title)
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                        .frame(maxHeight: 200)
                        .padding(.horizontal)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                    }
                }
            }
        } else {
            ZStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 20) {
                    Text(LocalizationManager.shared.localizedString(for: "findtalk.explore"))
                        .font(.title)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top)
                    // --- SEARCH BAR ---
                    VStack(spacing: 0) {
                        HStack {
                            HStack {
                                TextField("Search talks or tools...", text: $searchText, onEditingChanged: { editing in
                                    showSuggestions = editing && !searchText.isEmpty
                                }, onCommit: {
                                    performSearch()
                                })
                                .padding(.vertical, 10)
                                .padding(.leading, 12)
                                .foregroundColor(.primary)
                                .accentColor(.blue)
                                .onChange(of: searchText) { newValue in
                                    if !newValue.isEmpty {
                                        fetchSuggestions(for: newValue)
                                        showSuggestions = true
                                    } else {
                                        suggestions = []
                                        showSuggestions = false
                                    }
                                }
                                Button(action: {
                                    performSearch()
                                }) {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.blue)
                                }
                                .padding(.trailing, 12)
                            }
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    // --- END SEARCH BAR ---
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(categories, id: \.key) { category in
                            let title = LocalizationManager.shared.localizedString(for: "findtalk.\(category.key)")
                            let desc = LocalizationManager.shared.localizedString(for: "findtalk.\(category.key)_desc")
                            if category.key == "hazards" {
                                Button(action: onHazardTap) {
                                    tileView(title: title, desc: desc, icon: category.icon)
                                }
                            } else if category.key == "industry" {
                                Button(action: onIndustryTap) {
                                    tileView(title: title, desc: desc, icon: category.icon)
                                }
                            } else if category.key == "calendar" {
                                Button(action: { showCalendar = true }) {
                                    tileView(title: title, desc: desc, icon: category.icon)
                                }
                            } else if category.key == "translate" {
                                Button(action: { showTranslate = true }) {
                                    tileView(title: title, desc: desc, icon: category.icon)
                                }
                            } else if category.key == "send_talk" {
                                Button(action: { showShareTalkInfo = true }) {
                                    tileView(title: title, desc: desc, icon: category.icon)
                                }
                            } else if category.key == "tools" {
                                Button(action: { showTools = true }) {
                                    tileView(title: title, desc: desc, icon: category.icon)
                                }
                            } else {
                                tileView(title: title, desc: desc, icon: category.icon)
                            }
                        }
                    }
                    Spacer()
                    NavigationLink(destination: UpgradePlanView(), isActive: $showUpgrade) { EmptyView() }
                    NavigationLink(destination: CalendarView(), isActive: $showCalendar) { EmptyView() }
                    NavigationLink(destination: LanguageSelectionView(), isActive: $showTranslate) { EmptyView() }
                    NavigationLink(destination: ShareTalkInfoView(), isActive: $showShareTalkInfo) { EmptyView() }
                    NavigationLink(destination: ToolsView(), isActive: $showTools) { EmptyView() }
                    NavigationLink(destination: selectedTalk.map { TalkDetailView(talk: $0) }, isActive: Binding(get: { selectedTalk != nil }, set: { if !$0 { selectedTalk = nil } })) { EmptyView() }
                    NavigationLink(destination: selectedTool.map { ToolDetailView(tool: $0) }, isActive: Binding(get: { selectedTool != nil }, set: { if !$0 { selectedTool = nil } })) { EmptyView() }
                    NavigationLink(destination: SearchResultsView(results: searchResults, query: searchText, onTalkTap: { talk in selectedTalk = talk }, onToolTap: { tool in selectedTool = tool }), isActive: $navigateToSearchResults) { EmptyView() }
                    HStack {
                        Spacer()
                        Button(action: { showUpgrade = true }) {
                            Text(LocalizationManager.shared.localizedString(for: "button.access_more"))
                                .font(.footnote)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .cornerRadius(20)
                        }
                        .padding(.trailing, 32)
                        .padding(.bottom, 24)
                    }
                }
                .background(Color.white.ignoresSafeArea())
                // Suggestions dropdown overlay
                if showSuggestions && !suggestions.isEmpty {
                    VStack {
                        Spacer().frame(height: 130) // Adjusted for iPhone search bar height
                        List(suggestions, id: \ .id) { suggestion in
                            Button(action: {
                                showSuggestions = false
                                switch suggestion {
                                case .talk(let talk):
                                    selectedTalk = talk
                                case .tool(let toolTitle):
                                    fetchToolDetail(for: toolTitle)
                                }
                            }) {
                                HStack {
                                    Image(systemName: suggestionIcon(for: suggestion))
                                        .foregroundColor(.blue)
                                    Text(suggestion.title)
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                        .frame(maxHeight: 200)
                        .padding(.horizontal)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                    }
                }
            }
        }
    }

    private func tileView(title: String, desc: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.black)
                Spacer()
            }
            Text(title)
                .font(.headline)
                .foregroundColor(.blue)
            Text(desc)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }

    func fetchSuggestions(for query: String) {
        let token = UserDefaults.standard.string(forKey: "access_token") ?? ""
        let language = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
        var fetchedTalks: [TalkModel] = []
        var fetchedTools: [Tool] = []
        let group = DispatchGroup()
        group.enter()
        NetworkService.shared.getTalks(token: token, language: language) { result in
            switch result {
            case .success(let talks):
                fetchedTalks = talks
            case .failure:
                break
            }
            group.leave()
        }
        group.enter()
        NetworkService.shared.getTools(token: token, language: language) { result in
            switch result {
            case .success(let tools):
                fetchedTools = tools
            case .failure:
                break
            }
            group.leave()
        }
        group.notify(queue: .main) {
            let talkSuggestions = fetchedTalks.filter { $0.title.localizedCaseInsensitiveContains(query) }.map { DashboardView.SearchSuggestion.talk($0) }
            let toolSuggestions = fetchedTools.filter { $0.title.localizedCaseInsensitiveContains(query) }.map { DashboardView.SearchSuggestion.tool($0.title) }
            suggestions = talkSuggestions + toolSuggestions
        }
    }

    func performSearch() {
        searchResults = suggestions
        navigateToSearchResults = true
        showSuggestions = false
    }

    func suggestionIcon(for suggestion: DashboardView.SearchSuggestion) -> String {
        switch suggestion {
        case .talk: return "text.bubble"
        case .tool: return "wrench"
        }
    }

    func fetchToolDetail(for title: String) {
        let token = UserDefaults.standard.string(forKey: "access_token") ?? ""
        let language = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
        NetworkService.shared.getTools(token: token, language: language) { result in
            switch result {
            case .success(let tools):
                if let tool = tools.first(where: { $0.title == title }) {
                    DispatchQueue.main.async {
                        selectedTool = tool
                    }
                }
            case .failure:
                break
            }
        }
    }
}
