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

    var body: some View {
        NavigationStack {
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
                        ForEach(history) { item in
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
            .background(
                NavigationLink(destination: SettingsView(), isActive: $showSettings) { EmptyView() }
                    .hidden()
            )
            .background(
                NavigationLink(destination: LanguageSelectionView(), isActive: $showLanguage) { EmptyView() }
                    .hidden()
            )
            .sheet(isPresented: $showHelpCenter) {
                TicketSubmissionView()
            }
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
                        openTalk(item)
                    }
                }
                Button("Cancel", role: .cancel) {}
            }
            NavigationLink(
                destination: openTalkModel.map { TalkDetailView(talk: $0) },
                isActive: Binding(
                    get: { openTalkModel != nil },
                    set: { if !$0 { openTalkModel = nil } }
                )
            ) { EmptyView() }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(activityItems: shareContent)
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
    private func openTalk(_ item: HistoryItem) {
        NetworkService.shared.getTalkByTitle(token: accessToken, title: item.talk_title) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let talk):
                    self.openTalkModel = talk
                case .failure(let error):
                    print("Failed to fetch talk: \(error)")
                }
            }
        }
    }
}
