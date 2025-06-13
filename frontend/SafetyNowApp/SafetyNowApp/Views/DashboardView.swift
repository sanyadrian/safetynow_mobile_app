import SwiftUI
import PDFKit

struct DashboardView: View {
    @AppStorage("access_token") var accessToken: String = ""
    @AppStorage("username") var storedUsername: String = ""
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
    @State private var showTalkDetail: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
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
                                        Image(systemName: "bell")
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
                                    // PROMO BOX
                                    VStack(alignment: .center, spacing: 8) {
                                        Text(LocalizationManager.shared.localizedString(for: "dashboard.promo_title"))
                                            .foregroundColor(.blue)
                                            .bold()
                                            .font(.title2)
                                        Text(LocalizationManager.shared.localizedString(for: "dashboard.promo_subtitle"))
                                            .foregroundColor(.gray)
                                            .font(.title3)
                                        Text(LocalizationManager.shared.localizedString(for: "dashboard.promo_action"))
                                            .font(.title3)
                                            .foregroundColor(.blue)
                                            .underline()
                                    }
                                    .padding(.horizontal, 80)
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
                                                }
                                                .popover(isPresented: $showPopover, attachmentAnchor: .point(.trailing), arrowEdge: .trailing) {
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
                                    Image(systemName: "bell")
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

                                // PROMO BOX
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(LocalizationManager.shared.localizedString(for: "dashboard.promo_title"))
                                        .foregroundColor(.blue)
                                        .bold()
                                    Text(LocalizationManager.shared.localizedString(for: "dashboard.promo_subtitle"))
                                        .foregroundColor(.gray)
                                    Text(LocalizationManager.shared.localizedString(for: "dashboard.promo_action"))
                                        .font(.footnote)
                                        .foregroundColor(.blue)
                                        .underline()
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(16)
                                .padding(.horizontal)

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
                ShareSheet(activityItems: shareContent)
            }
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
}
