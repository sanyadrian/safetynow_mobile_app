import SwiftUI

struct TalkDetailView: View {
    let talk: TalkModel
    var onBack: (() -> Void)? = nil
    @AppStorage("access_token") var accessToken: String = ""
    @AppStorage("selectedLanguage") var selectedLanguage: String = "en"
    @State private var likeCount: Int = 0
    @State private var isLiked: Bool = false
    @State private var isLoading: Bool = false
    @State private var showShareSheet = false
    @State private var shareContent: [Any] = []
    @State private var showUpgrade = false

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                if let onBack = onBack {
                    Button(action: { onBack() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                }
                Spacer()
                Text("Safety Talk")
                    .font(.title2)
                    .bold()
                Spacer()
                Menu {
                    Button(action: {
                        if let pdfURL = createPDF(for: talk.title, description: talk.description) {
                            shareContent = [pdfURL]
                            showShareSheet = true
                        }
                    }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title2)
                        .foregroundColor(.black)
                }
            }
            .padding([.horizontal, .top])

            // Talk title with icon
            HStack(spacing: 8) {
                Image(systemName: "doc.text")
                    .foregroundColor(.black)
                Text(talk.title)
                    .font(.headline)
                    .bold()
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 24)

            // Talk description/content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let hazard = talk.hazard {
                        let translatedHazard = Translations.translateHazard(hazard, language: selectedLanguage)
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                            Text(translatedHazard)
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        }
                        .padding(.horizontal)
                        .onAppear {
                            print("Detail View - Hazard: \(hazard) -> \(translatedHazard) (Language: \(selectedLanguage))")
                        }
                    }
                    
                    if let industry = talk.industry {
                        let translatedIndustry = Translations.translateIndustry(industry, language: selectedLanguage)
                        HStack {
                            Image(systemName: "building.2")
                                .foregroundColor(.blue)
                            Text(translatedIndustry)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal)
                        .onAppear {
                            print("Detail View - Industry: \(industry) -> \(translatedIndustry) (Language: \(selectedLanguage))")
                        }
                    }
                    
                    // Custom rendering for description with subtitles and spacing
                    if let description = talk.description {
                        VStack(alignment: .leading, spacing: 0) {
                            let lines = description.components(separatedBy: .newlines)
                            ForEach(Array(lines.enumerated()), id: \.offset) { tuple in
                                let idx = tuple.offset
                                let line = tuple.element
                                let trimmed = line.trimmingCharacters(in: .whitespaces)
                                if trimmed.isEmpty {
                                    Spacer().frame(height: 10)
                                } else if trimmed == trimmed.uppercased() && trimmed.rangeOfCharacter(from: .letters) != nil {
                                    Spacer().frame(height: idx == 0 ? 0 : 16)
                                    Text(trimmed)
                                        .font(.body).bold()
                                        .foregroundColor(.black)
                                    Spacer().frame(height: 8)
                                } else {
                                    Text(trimmed)
                        .font(.body)
                        .foregroundColor(.black)
                                    Spacer().frame(height: 6)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color(.systemGray4).opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    
                    HStack(spacing: 16) {
                        Button(action: {
                            toggleLike()
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                                    .foregroundColor(isLiked ? .blue : .gray)
                                if likeCount > 0 {
                                    Text("\(likeCount)")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .disabled(isLoading)
                        
                        Button(action: {
                            if let pdfURL = createPDF(for: talk.title, description: talk.description) {
                                shareContent = [pdfURL]
                                showShareSheet = true
                            }
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showUpgrade = true
                        }) {
                            Text(LocalizationManager.shared.localizedString(for: "button.access_more"))
                                .font(.footnote)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                }
                .padding([.horizontal, .top])
            }

            Spacer()
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            print("Detail View - Selected Language: \(selectedLanguage)")
            print("Detail View - Talk: \(talk.title)")
            print("Detail View - Hazard: \(talk.hazard ?? "none")")
            print("Detail View - Industry: \(talk.industry ?? "none")")
            print("Detail View - Description: \(talk.description ?? "nil")")
            NetworkService.shared.addToHistory(token: accessToken, talkTitle: talk.title) { result in
                switch result {
                case .success:
                    print("Successfully added talk to history")
                case .failure(let error):
                    print("Failed to add talk to history: \(error.localizedDescription)")
                }
            }
            fetchLikeStatus()
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: shareContent)
        }
        NavigationLink(destination: UpgradePlanView(), isActive: $showUpgrade) { EmptyView() }
    }
    
    private func fetchLikeStatus() {
        guard let url = URL(string: "\(NetworkService.shared.baseURL)/talks/\(talk.id)/likes") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data,
               let likeInfo = try? JSONDecoder().decode(LikeInfo.self, from: data) {
                DispatchQueue.main.async {
                    self.likeCount = likeInfo.likeCount
                    self.isLiked = likeInfo.userLiked
                }
            }
        }.resume()
    }
    
    private func toggleLike() {
        isLoading = true
        guard let url = URL(string: "\(NetworkService.shared.baseURL)/talks/\(talk.id)/like") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if error == nil {
                    isLiked.toggle()
                    likeCount += isLiked ? 1 : -1
                }
            }
        }.resume()
    }
}

struct LikeInfo: Decodable {
    let likeCount: Int
    let userLiked: Bool
    
    enum CodingKeys: String, CodingKey {
        case likeCount = "like_count"
        case userLiked = "user_liked"
    }
}

#Preview {
    TalkDetailView(
        talk: TalkModel(
            id: 1,
            title: "Test Talk",
            category: "General",
            description: "A test description.",
            hazard: "Fire",
            industry: "Construction",
            language: "en",
            related_title: "test-talk",
            likeCount: 0,
            userLiked: false
        )
    )
}
