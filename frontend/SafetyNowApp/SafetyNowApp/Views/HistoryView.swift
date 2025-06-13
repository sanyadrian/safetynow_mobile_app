import SwiftUI
import PDFKit

struct HistoryView: View {
    @AppStorage("access_token") var accessToken: String = ""
    @State private var history: [HistoryItem] = []
    @State private var popularTalks: [TalkModel] = []
    @Binding var selectedTab: Tab
    @State private var showActionSheet = false
    @State private var selectedHistoryItem: HistoryItem?
    @State private var openTalkModel: TalkModel? = nil
    @State private var showPopularActionSheet = false
    @State private var selectedPopularTalk: TalkModel?
    @State private var openPopularTalkModel: TalkModel? = nil
    @State private var showShareSheet = false
    @State private var shareContent: [Any] = []
    @State private var showPopover = false
    @State private var popoverItem: HistoryItem? = nil
    @State private var showPopularPopover = false
    @State private var popoverPopularTalk: TalkModel? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(LocalizationManager.shared.localizedString(for: "history.title"))
                            .font(.title)
                            .bold()
                            .padding(.top)

                        Text(LocalizationManager.shared.localizedString(for: "history.last_talks"))
                            .font(.headline)
                            .padding(.top)

                        var filteredHistory: [HistoryItem] {
                            let currentLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
                            return history.filter { $0.language == currentLanguage }
                        }

                        ForEach(filteredHistory) { item in
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .foregroundColor(.blue)
                                Text(item.talk_title)
                                    .font(.subheadline)
                                Spacer()
                                Button(action: {
                                    if UIDevice.current.userInterfaceIdiom == .pad {
                                        popoverItem = item
                                        showPopover = true
                                    } else {
                                        selectedHistoryItem = item
                                        showActionSheet = true
                                    }
                                }) {
                                    Image(systemName: "ellipsis")
                                        .foregroundColor(.gray)
                                }
                                .popover(isPresented: $showPopover, attachmentAnchor: .rect(.bounds), arrowEdge: .bottom) {
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
                                                openTalk(item)
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
                            .cornerRadius(16)
                        }

                        Text(LocalizationManager.shared.localizedString(for: "history.most_popular"))
                            .font(.headline)
                            .padding(.top)

                        ForEach(popularTalks) { talk in
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading) {
                                    Text(talk.title)
                                        .font(.subheadline)
                                    if let likeCount = talk.likeCount {
                                        Text("\(likeCount) likes")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                Spacer()
                                Button(action: {
                                    if UIDevice.current.userInterfaceIdiom == .pad {
                                        popoverPopularTalk = talk
                                        showPopularPopover = true
                                    } else {
                                        selectedPopularTalk = talk
                                        showPopularActionSheet = true
                                    }
                                }) {
                                    Image(systemName: "ellipsis")
                                        .foregroundColor(.gray)
                                }
                                .popover(isPresented: $showPopularPopover, attachmentAnchor: .rect(.bounds), arrowEdge: .bottom) {
                                    VStack(spacing: 16) {
                                        Button("Share") {
                                            if let talk = popoverPopularTalk {
                                                sharePopularTalk(talk)
                                            }
                                            showPopularPopover = false
                                        }
                                        Button("Open") {
                                            if let talk = popoverPopularTalk {
                                                openPopularTalk(talk)
                                            }
                                            showPopularPopover = false
                                        }
                                        Button("Cancel", role: .cancel) {
                                            showPopularPopover = false
                                        }
                                    }
                                    .padding()
                                    .frame(width: 250)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                        }

                        Spacer(minLength: 24)
                    }
                    .padding(.horizontal)
                }
            }
            NavigationLink(
                destination: openTalkModel.map { TalkDetailView(talk: $0) },
                isActive: Binding(
                    get: { openTalkModel != nil },
                    set: { if !$0 { openTalkModel = nil } }
                )
            ) { EmptyView() }
            NavigationLink(
                destination: openPopularTalkModel.map { TalkDetailView(talk: $0) },
                isActive: Binding(
                    get: { openPopularTalkModel != nil },
                    set: { if !$0 { openPopularTalkModel = nil } }
                )
            ) { EmptyView() }
        }
        .confirmationDialog(LocalizationManager.shared.localizedString(for: "history.options"), isPresented: $showActionSheet, titleVisibility: .visible) {
            Button(LocalizationManager.shared.localizedString(for: "history.delete"), role: .destructive) {
                if let item = selectedHistoryItem {
                    deleteFromHistory(item)
                }
            }
            Button(LocalizationManager.shared.localizedString(for: "history.share")) {
                if let item = selectedHistoryItem {
                    shareTalk(item)
                }
            }
            Button(LocalizationManager.shared.localizedString(for: "history.open")) {
                if let item = selectedHistoryItem {
                    openTalk(item)
                }
            }
            Button(LocalizationManager.shared.localizedString(for: "history.cancel"), role: .cancel) {}
        }
        .confirmationDialog(LocalizationManager.shared.localizedString(for: "history.options"), isPresented: $showPopularActionSheet, titleVisibility: .visible) {
            Button(LocalizationManager.shared.localizedString(for: "history.share")) {
                if let talk = selectedPopularTalk {
                    sharePopularTalk(talk)
                }
            }
            Button(LocalizationManager.shared.localizedString(for: "history.open")) {
                if let talk = selectedPopularTalk {
                    openPopularTalk(talk)
                }
            }
            Button(LocalizationManager.shared.localizedString(for: "history.cancel"), role: .cancel) {}
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: shareContent)
        }
        .onAppear {
            // Fetch history
            NetworkService.shared.getHistory(token: accessToken) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let items):
                        self.history = items
                    case .failure(let error):
                        print("Error fetching history: \(error.localizedDescription)")
                    }
                }
            }
            
            // Fetch popular talks
            fetchPopularTalks()
        }
    }
    
    private func fetchPopularTalks() {
        let currentLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
        guard let url = URL(string: "\(NetworkService.shared.baseURL)/talks/popular?language=\(currentLanguage)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let talks = try decoder.decode([TalkModel].self, from: data)
                    DispatchQueue.main.async {
                        self.popularTalks = talks
                        print("Fetched \(talks.count) popular talks")
                    }
                } catch {
                    print("Error decoding popular talks: \(error)")
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Received JSON: \(jsonString)")
                    }
                }
            } else if let error = error {
                print("Error fetching popular talks: \(error.localizedDescription)")
            }
        }.resume()
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
    private func sharePopularTalk(_ talk: TalkModel) {
        let pdfURL = createPDF(for: talk.title, description: talk.description)
        if let pdfURL = pdfURL {
            shareContent = [pdfURL]
            showShareSheet = true
        }
    }
    private func openPopularTalk(_ talk: TalkModel) {
        self.openPopularTalkModel = talk
    }
}