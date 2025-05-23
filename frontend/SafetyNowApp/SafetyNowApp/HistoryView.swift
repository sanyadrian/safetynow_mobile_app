import SwiftUI

struct HistoryView: View {
    @AppStorage("access_token") var accessToken: String = ""
    @State private var history: [HistoryItem] = []
    @State private var popularTalks: [TalkModel] = []
    @Binding var selectedTab: Tab
    @State private var showActionSheet = false
    @State private var selectedHistoryItem: HistoryItem?
    @State private var openTalkModel: TalkModel? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("History")
                            .font(.title)
                            .bold()
                            .padding(.top)

                        Text("Last Talks")
                            .font(.headline)
                            .padding(.top)

                        ForEach(history) { item in
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .foregroundColor(.blue)
                                Text(item.talk_title)
                                    .font(.subheadline)
                                Spacer()
                                Button(action: {
                                    selectedHistoryItem = item
                                    showActionSheet = true
                                }) {
                                    Image(systemName: "ellipsis")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                        }

                        Text("Most Popular")
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
                                Image(systemName: "ellipsis")
                                    .foregroundColor(.gray)
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
        guard let url = URL(string: "http://localhost:8000/talks/popular") else { return }
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
        print("Share: \(item.talk_title)")
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
