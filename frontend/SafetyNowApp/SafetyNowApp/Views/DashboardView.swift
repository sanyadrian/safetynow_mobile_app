import SwiftUI
import PDFKit
import Combine

struct DashboardView: View {
    @AppStorage("access_token") var accessToken: String = ""
    @AppStorage("username") var storedUsername: String = ""
    @AppStorage("notificationsEnabled") var notificationsEnabled: Bool = false
    @State private var history: [HistoryItem] = []
    @Binding var selectedTab: Tab
    @State private var navigateToFindTalk = false
    @State private var showTicketSubmission = false
    @State private var showCalendar = false
    @State private var showMenu = false
    @State private var showSettings = false
    @State private var showLanguage = false
    @State private var showHelpCenter = false
    @State private var showActionSheet = false
    @State private var selectedHistoryItem: HistoryItem?
    @State private var openTalkModel: TalkModel? = nil
    @State private var showShareSheet = false
    @State private var shareContent: [Any] = []
    @State private var showPopover = false
    @State private var popoverItem: HistoryItem? = nil
    @State private var shouldNavigateToTalkDetail = false
    @State private var searchResultTalk: TalkModel? = nil
    @State private var showTalkDetail: Bool = false
    @State private var showUpgrade = false
    // Search state
    @State private var searchText: String = ""
    @State private var showSuggestions: Bool = false
    @State private var suggestions: [SearchSuggestion] = []
    @State private var navigateToSearchResults = false
    @State private var searchResults: [SearchSuggestion] = []
    @State private var searchCancellable: AnyCancellable?
    @State private var selectedTalk: TalkModel? = nil
    @State private var selectedTool: Tool? = nil

    enum SearchSuggestion: Identifiable, Hashable {
        case talk(TalkModel)
        case tool(String)
        var id: String {
            switch self {
            case .talk(let talk): return "talk-\(talk.id)"
            case .tool(let tool): return "tool-\(tool)"
            }
        }
        var title: String {
            switch self {
            case .talk(let talk): return talk.title
            case .tool(let tool): return tool
            }
        }
    }

    var body: some View {
        NavigationStack {
            /*
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
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
                }
                // Suggestions dropdown overlay
                if showSuggestions && !suggestions.isEmpty {
                    VStack {
                        Spacer().frame(height: 100) // Adjust this value to match your search bar's vertical position
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
            */
            Group {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    ScrollView {
                        VStack(alignment: .center, spacing: 48) {
                            // Title
                            Text("Dashboard")
                                .font(.system(size: 48, weight: .bold))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                            VStack(spacing: 40) {
                                HStack {
                                    Button(action: { showMenu = true }) {
                                        Image(systemName: "line.horizontal.3")
                                    }
                                    Spacer()
                                    VStack(alignment: .center) {
                                        Text(LocalizationManager.shared.localizedString(for: "dashboard.welcome_back"))
                                            .font(.title2)
                                            .foregroundColor(.gray)
                                        Text("\(storedUsername)")
                                            .font(.title)
                                            .bold()
                                    }
                                    Spacer()
                                    Button(action: { notificationsEnabled.toggle() }) {
                                        Image(systemName: notificationsEnabled ? "bell.fill" : "bell")
                                            .foregroundColor(notificationsEnabled ? .blue : .gray)
                                    }
                                }
                                .padding(.horizontal, 80)
                                HStack(spacing: 32) {
                                    actionTile(title: LocalizationManager.shared.localizedString(for: "dashboard.find_talk"), systemIcon: "text.bubble") {
                                        selectedTab = .search
                                    }
                                    actionTile(title: LocalizationManager.shared.localizedString(for: "dashboard.talk_to_safetynow"), systemIcon: "mic") {
                                        showTicketSubmission = true
                                    }
                                }
                                .padding(.horizontal, 80)
                                // PROMO BOX (Unified for iPad and iPhone)
                                Button(action: { showUpgrade = true }) {
                                    VStack(alignment: .center, spacing: 12) {
                                        Image("SafetyNow-LogoArtboard-1-1")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 160, height: 160)
                                            .padding(.top, 8)
                                        Text(LocalizationManager.shared.localizedString(for: "dashboard.promo_title"))
                                            .foregroundColor(.blue)
                                            .bold()
                                            .font(.title2)
                                            .multilineTextAlignment(.center)
                                        Text(LocalizationManager.shared.localizedString(for: "dashboard.promo_subtitle"))
                                            .foregroundColor(.gray)
                                            .font(.title3)
                                            .multilineTextAlignment(.center)
                                        Text(LocalizationManager.shared.localizedString(for: "dashboard.promo_action"))
                                            .font(.title3)
                                            .foregroundColor(.blue)
                                            .underline()
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 8)
                                }
                                .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(16)
                                VStack(alignment: .leading, spacing: 16) {
                                    Text(LocalizationManager.shared.localizedString(for: "dashboard.history"))
                                        .font(.title2)
                                        .bold()
                                    ForEach(filteredHistory) { item in
                                        HStack {
                                            Image(systemName: "doc.text")
                                                .foregroundColor(.blue)
                                            VStack(alignment: .leading) {
                                                Text(item.talk_title)
                                                    .font(.title3)
                                            }
                                            Spacer()
                                            Button(action: {
                                                popoverItem = item
                                                showPopover = true
                                            }) {
                                                Image(systemName: "ellipsis")
                                                    .frame(width: 44, height: 44)
                                            }
                                            .popover(
                                                isPresented: Binding(
                                                    get: { showPopover && popoverItem?.id == item.id },
                                                    set: { newValue in
                                                        showPopover = newValue
                                                        if !newValue { popoverItem = nil }
                                                    }
                                                ),
                                                attachmentAnchor: .rect(.bounds),
                                                arrowEdge: .trailing
                                            ) {
                                                VStack(spacing: 16) {
                                                    Button("Delete from history", role: .destructive) {
                                                        if let item = popoverItem {
                                                            deleteFromHistory(item)
                                                        }
                                                        showPopover = false
                                                    }
                                                    Button("Share") {
                                                        if let item = popoverItem {
                                                            shareTalk(item)
                                                        }
                                                        showPopover = false
                                                    }
                                                    Button("Open") {
                                                        if let item = popoverItem {
                                                            openTalkWithPopoverClose(item)
                                                        }
                                                        showPopover = false
                                                    }
                                                    Button("Cancel", role: .cancel) {
                                                        showPopover = false
                                                    }
                                                }
                                                .padding()
                                                .frame(width: 250)
                                            }
                                            .id(item.id)
                                        }
                                        .padding()
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                    }
                                }
                                .padding(.horizontal, 80)
                            }
                            .padding(.vertical, 40)
                        }
                        .padding(.vertical, 60)
                    }
                } else {
                    ScrollView {
                        VStack {
                            HStack {
                                Button(action: { showMenu = true }) {
                                    Image(systemName: "line.horizontal.3")
                                }
                                Spacer()
                                VStack(alignment: .center) {
                                    Text(LocalizationManager.shared.localizedString(for: "dashboard.welcome_back"))
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Text("\(storedUsername)")
                                        .font(.headline)
                                        .bold()
                                }
                                Spacer()
                                Button(action: { notificationsEnabled.toggle() }) {
                                    Image(systemName: notificationsEnabled ? "bell.fill" : "bell")
                                        .foregroundColor(notificationsEnabled ? .blue : .gray)
                                }
                            }
                            .padding(.horizontal)

                            HStack(spacing: 16) {
                                actionTile(title: LocalizationManager.shared.localizedString(for: "dashboard.find_talk"), systemIcon: "text.bubble") {
                                    selectedTab = .search
                                }
                                actionTile(title: LocalizationManager.shared.localizedString(for: "dashboard.talk_to_safetynow"), systemIcon: "mic") {
                                    showTicketSubmission = true
                                }
                            }
                            .padding(.horizontal)

                            // PROMO BOX (Unified for iPad and iPhone)
                            Button(action: { showUpgrade = true }) {
                                VStack(alignment: .center, spacing: 12) {
                                    Image("SafetyNow-LogoArtboard-1-1")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 160, height: 160)
                                        .padding(.top, 8)
                                    Text(LocalizationManager.shared.localizedString(for: "dashboard.promo_title"))
                                        .foregroundColor(.blue)
                                        .bold()
                                        .font(.title2)
                                        .multilineTextAlignment(.center)
                                    Text(LocalizationManager.shared.localizedString(for: "dashboard.promo_subtitle"))
                                        .foregroundColor(.gray)
                                        .font(.title3)
                                        .multilineTextAlignment(.center)
                                    Text(LocalizationManager.shared.localizedString(for: "dashboard.promo_action"))
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                        .underline()
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 8)
                            }
                            .frame(maxWidth: .infinity)
                                .background(Color(.systemGray6))
                                .cornerRadius(16)

                            VStack(alignment: .leading, spacing: 8) {
                                Text(LocalizationManager.shared.localizedString(for: "dashboard.history"))
                                    .font(.title3)
                                    .bold()
                                ForEach(filteredHistory) { item in
                                    HStack {
                                        Image(systemName: "doc.text")
                                            .foregroundColor(.blue)
                                        VStack(alignment: .leading) {
                                            Text(item.talk_title)
                                                .font(.body)
                                        }
                                        Spacer()
                                        Button(action: {
                                            selectedHistoryItem = item
                                            showActionSheet = true
                                        }) {
                                            Image(systemName: "ellipsis")
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.horizontal)

                            Spacer()
                        }
                        .padding(.top)
                    }
                }
            }
            .sheet(isPresented: $showTicketSubmission) {
                TicketSubmissionView()
            }
            .sheet(isPresented: $showMenu) {
                VStack(spacing: 32) {
                    Spacer().frame(height: 32)
                    Text(LocalizationManager.shared.localizedString(for: "dashboard.menu"))
                        .font(.title2)
                        .bold()
                    VStack(spacing: 24) {
                        Button(action: { showSettings = true; showMenu = false }) {
                            menuRow(title: LocalizationManager.shared.localizedString(for: "menu.settings"))
                        }
                        Button(action: { showLanguage = true; showMenu = false }) {
                            menuRow(title: LocalizationManager.shared.localizedString(for: "menu.language"))
                        }
                        Button(action: { showHelpCenter = true; showMenu = false }) {
                            menuRow(title: LocalizationManager.shared.localizedString(for: "menu.help_center"))
                        }
                    }
                    .padding(.horizontal)
                    Spacer()
                }
                .presentationDetents([.medium])
            }
            .sheet(isPresented: $showHelpCenter) {
                TicketSubmissionView()
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = shareContent.first as? URL {
                    ShareSheet(activityItems: [url])
                }
            }
            .id((shareContent.first as? URL)?.absoluteString ?? UUID().uuidString)
            .background(
                NavigationLink(destination: SettingsView(), isActive: $showSettings) { EmptyView() }
                    .hidden()
            )
            .background(
                NavigationLink(destination: LanguageSelectionView(), isActive: $showLanguage) { EmptyView() }
                    .hidden()
            )
            .confirmationDialog("Options", isPresented: $showActionSheet, titleVisibility: .visible) {
                Button("Delete from history", role: .destructive) {
                    if let item = selectedHistoryItem {
                        deleteFromHistory(item)
                    }
                }
                Button("Share") {
                    if let item = selectedHistoryItem {
                        shareTalk(item)
                    }
                }
                Button("Open") {
                    if let item = selectedHistoryItem {
                        openTalkWithPopoverClose(item)
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            if UIDevice.current.userInterfaceIdiom == .pad {
                NavigationLink(
                    destination: TalkDetailView(talk: openTalkModel ?? placeholderTalk),
                    isActive: $showTalkDetail
                ) { EmptyView() }
            } else {
                NavigationLink(
                    destination: openTalkModel.map { TalkDetailView(talk: $0) },
                    isActive: Binding(
                        get: { openTalkModel != nil },
                        set: { if !$0 { openTalkModel = nil } }
                    )
                ) { EmptyView() }
            }
            NavigationLink(destination: UpgradePlanView(), isActive: $showUpgrade) { EmptyView() }
            NavigationLink(destination: selectedTalk.map { TalkDetailView(talk: $0) }, isActive: Binding(get: { selectedTalk != nil }, set: { if !$0 { selectedTalk = nil } })) { EmptyView() }
            NavigationLink(destination: searchResultTalk.map { TalkDetailView(talk: $0) }, isActive: Binding(get: { searchResultTalk != nil }, set: { if !$0 { searchResultTalk = nil } })) { EmptyView() }
            NavigationLink(destination: selectedTool.map { ToolDetailView(tool: $0) }, isActive: Binding(get: { selectedTool != nil }, set: { if !$0 { selectedTool = nil } })) { EmptyView() }
            NavigationLink(destination: SearchResultsView(results: searchResults, query: searchText, onTalkTap: { talk in 
                print("DEBUG: Talk tapped in search results: \(talk.title)")
                searchResultTalk = talk
                navigateToSearchResults = false // Close search results when navigating to talk
                print("DEBUG: searchResultTalk set to: \(searchResultTalk?.title ?? "nil")")
            }, onToolTap: { tool in selectedTool = tool }), isActive: $navigateToSearchResults) { EmptyView() }
        }
        .onAppear {
            NetworkService.shared.getHistory(token: accessToken) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let items):
                        self.history = items
                    case .failure(let error):
                        print("\(error.localizedDescription)")
                    }
                }
            }
        }
        .onChange(of: notificationsEnabled) { enabled in
            if enabled {
                NotificationManager.shared.registerForPushNotifications()
            } else {
                NotificationManager.shared.disableNotifications()
            }
        }
    }

    private func actionTile(title: String, systemIcon: String, action: @escaping () -> Void) -> some View {
        VStack {
            Button(action: action) {
                VStack {
                    Image(systemName: systemIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    Text(title)
                        .font(.footnote)
                        .foregroundColor(.primary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }

    private func menuRow(title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            Spacer()
            ZStack {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 32, height: 32)
                Image(systemName: "arrow.right")
                    .foregroundColor(.blue)
            }
        }
    }

    private func deleteFromHistory(_ item: HistoryItem) {
        NetworkService.shared.deleteHistoryItem(token: accessToken, historyId: item.id) { result in
            DispatchQueue.main.async {
                if case .success = result {
                    history.removeAll { $0.id == item.id }
                }
            }
        }
    }
    private func shareTalk(_ item: HistoryItem) {
        NetworkService.shared.getTalkByTitle(token: accessToken, title: item.talk_title) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let talk):
                    let pdfURL = createPDF(for: talk.title, description: talk.description)
                    if let pdfURL = pdfURL {
                        shareContent = [pdfURL]
                        showShareSheet = true
                    }
                case .failure:
                    let pdfURL = createPDF(for: item.talk_title, description: nil)
                    if let pdfURL = pdfURL {
                        shareContent = [pdfURL]
                        showShareSheet = true
                    }
                }
            }
        }
    }
    private func openTalkWithPopoverClose(_ item: HistoryItem) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            NetworkService.shared.getTalkByTitle(token: accessToken, title: item.talk_title) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let talk):
                        self.openTalkModel = talk
                        if UIDevice.current.userInterfaceIdiom == .pad {
                            self.showTalkDetail = true
                        } else {
                            self.shouldNavigateToTalkDetail = true
                        }
                    case .failure(let error):
                        print("Failed to fetch talk: \(error)")
                    }
                }
            }
        }
    }

    var filteredHistory: [HistoryItem] {
        let currentLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
        return history.filter { $0.language == currentLanguage }
    }

    private var placeholderTalk: TalkModel {
        TalkModel(id: -1, title: "", category: "", description: "", hazard: nil, industry: nil, language: "", related_title: "", likeCount: 0, userLiked: false)
    }

    // Dummy suggestion fetcher (replace with real API calls)
    func fetchSuggestions(for query: String) {
        let token = accessToken
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
            let talkSuggestions = fetchedTalks.filter { $0.title.localizedCaseInsensitiveContains(query) }.map { SearchSuggestion.talk($0) }
            let toolSuggestions = fetchedTools.filter { $0.title.localizedCaseInsensitiveContains(query) }.map { SearchSuggestion.tool($0.title) }
            DispatchQueue.main.async {
                suggestions = talkSuggestions + toolSuggestions
                showSuggestions = !suggestions.isEmpty
            }
        }
    }

    func performSearch() {
        searchResults = suggestions
        navigateToSearchResults = true
        showSuggestions = false
    }

    func suggestionIcon(for suggestion: SearchSuggestion) -> String {
        switch suggestion {
        case .talk: return "text.bubble"
        case .tool: return "wrench"
        }
    }

    func fetchToolDetail(for title: String) {
        let token = accessToken
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

// Dummy SearchResultsView
struct SearchResultsView: View {
    let results: [DashboardView.SearchSuggestion]
    let query: String
    let onTalkTap: (TalkModel) -> Void
    let onToolTap: (Tool) -> Void
    @AppStorage("access_token") var accessToken: String = ""
    @AppStorage("selectedLanguage") var selectedLanguage: String = "en"
    @State private var tools: [Tool] = []
    var body: some View {
        VStack {
            Text("Results for \"\(query)\"")
                .font(.title2)
                .padding()
            List(results, id: \ .id) { suggestion in
                Button(action: {
                    switch suggestion {
                    case .talk(let talk):
                        onTalkTap(talk)
                    case .tool(let toolTitle):
                        // Find the full Tool object for detail view
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
        }
    }
    func suggestionIcon(for suggestion: DashboardView.SearchSuggestion) -> String {
        switch suggestion {
        case .talk: return "text.bubble"
        case .tool: return "wrench"
        }
    }
    func fetchToolDetail(for title: String) {
        let token = accessToken
        let language = selectedLanguage
        NetworkService.shared.getTools(token: token, language: language) { result in
            switch result {
            case .success(let tools):
                if let tool = tools.first(where: { $0.title == title }) {
                    onToolTap(tool)
                }
            case .failure:
                break
            }
        }
    }
}
