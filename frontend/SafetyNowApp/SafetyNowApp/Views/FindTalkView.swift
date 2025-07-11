import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

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
    @State private var navigateToTalkDetail = false
    @State private var pendingSelectedTalk: TalkModel? = nil
    @State private var selectedTool: Tool? = nil

    var body: some View {
        VStack(spacing: 0) {
            // Explore title at the top
            Text(LocalizationManager.shared.localizedString(for: "findtalk.explore"))
                .font(.system(size: 48, weight: .bold))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top)

            // Search bar under Explore
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
                    showSuggestions = false
                    self.hideKeyboard()
                    performSearch()
                }) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.blue)
                }
                .padding(.trailing, 12)
                .buttonStyle(PlainButtonStyle())
                .zIndex(3) // Highest priority for search button
            }
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.top, 8)
            .zIndex(2) // Ensure search bar is above suggestions

            // Small gap to separate search bar from suggestions
            if showSuggestions && !suggestions.isEmpty {
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 4)
                    .zIndex(1)
            }

            // Suggestions dropdown (if needed)
            if showSuggestions && !suggestions.isEmpty {
                VStack(spacing: 0) {
                    ForEach(suggestions, id: \.id) { suggestion in
                        Button(action: {
                            showSuggestions = false
                            self.hideKeyboard()
                            switch suggestion {
                            case .talk(let talk):
                                selectedTalk = talk
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    navigateToTalkDetail = true
                                }
                            case .tool(let toolTitle):
                                fetchToolDetail(for: toolTitle)
                            }
                        }) {
                            HStack {
                                Image(systemName: suggestionIcon(for: suggestion))
                                    .foregroundColor(.blue)
                                Text(suggestion.title)
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if suggestion.id != suggestions.last?.id {
                            Divider()
                                .padding(.leading, 40)
                        }
                    }
                }
                .frame(maxHeight: 200)
                .padding(.horizontal)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 4)
                .zIndex(1) // Ensure suggestions are below search bar
            }

            // The rest of your content in a ScrollView
            ScrollView {
                VStack(alignment: .center, spacing: 48) {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                        ForEach(categories, id: \.key) { category in
                            let title = LocalizationManager.shared.localizedString(for: "findtalk.\(category.key)")
                            let desc = LocalizationManager.shared.localizedString(for: "findtalk.\(category.key)_desc")
                            if category.key == "hazards" {
                                Button(action: onHazardTap) {
                                    tileView(title: title, desc: desc, icon: category.icon)
                                }
                                .buttonStyle(PlainButtonStyle())
                            } else if category.key == "industry" {
                                Button(action: onIndustryTap) {
                                    tileView(title: title, desc: desc, icon: category.icon)
                                }
                                .buttonStyle(PlainButtonStyle())
                            } else if category.key == "calendar" {
                                Button(action: { showCalendar = true }) {
                                    tileView(title: title, desc: desc, icon: category.icon)
                                }
                                .buttonStyle(PlainButtonStyle())
                            } else if category.key == "translate" {
                                Button(action: { showTranslate = true }) {
                                    tileView(title: title, desc: desc, icon: category.icon)
                                }
                                .buttonStyle(PlainButtonStyle())
                            } else if category.key == "send_talk" {
                                Button(action: { showShareTalkInfo = true }) {
                                    tileView(title: title, desc: desc, icon: category.icon)
                                }
                                .buttonStyle(PlainButtonStyle())
                            } else if category.key == "tools" {
                                Button(action: { showTools = true }) {
                                    tileView(title: title, desc: desc, icon: category.icon)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 24)
                    NavigationLink(destination: selectedTool.map { ToolDetailView(tool: $0) }, isActive: Binding(get: { selectedTool != nil }, set: { if !$0 { selectedTool = nil } })) { EmptyView() }
                    NavigationLink(destination: SearchResultsView(results: searchResults, query: searchText, onTalkTap: { talk in 
                        pendingSelectedTalk = talk
                        // Do NOT set navigateToSearchResults = false here, so the search results remain in the stack
                    }, onToolTap: { tool in selectedTool = tool }), isActive: $navigateToSearchResults) { EmptyView() }
                    .onChange(of: pendingSelectedTalk) { newValue in
                        if let talk = newValue {
                            selectedTalk = talk
                            navigateToTalkDetail = true
                            pendingSelectedTalk = nil
                        }
                    }
                    NavigationLink(
                        destination: selectedTalk.map { TalkDetailView(talk: $0) },
                        isActive: $navigateToTalkDetail
                    ) { EmptyView() }
                    NavigationLink(destination: ToolsView(), isActive: $showTools) { EmptyView() }
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
            .scrollDismissesKeyboard(.interactively)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onTapGesture {
            self.hideKeyboard()
        }
        .sheet(isPresented: $showCalendar) {
            CalendarView()
        }
        .sheet(isPresented: $showTranslate) {
            LanguageSelectionView()
        }
        .sheet(isPresented: $showShareTalkInfo) {
            ShareTalkInfoView()
        }
        .sheet(isPresented: $showUpgrade) {
            UpgradePlanView()
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
        .contentShape(Rectangle()) // Make entire tile tappable
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
