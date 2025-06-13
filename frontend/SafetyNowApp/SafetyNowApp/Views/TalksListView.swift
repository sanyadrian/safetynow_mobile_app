import SwiftUI

enum TalkFilterType {
    case hazard
    case industry
}

struct TalkModel: Identifiable, Decodable, Hashable {
    let id: Int
    let title: String
    let category: String
    let description: String?
    let hazard: String?
    let industry: String?
    let language: String
    let related_title: String
    var likeCount: Int?
    var userLiked: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, title, category, description, hazard, industry, language, related_title
        case likeCount = "like_count"
        case userLiked = "user_liked"
    }
}

struct TalksListView: View {
    let filterType: TalkFilterType
    let filterValue: String
    let onTalkTap: (TalkModel) -> Void
    @AppStorage("access_token") var accessToken: String = ""
    @AppStorage("selectedLanguage") var selectedLanguage: String = "en"
    @State private var talks: [TalkModel] = []
    @State private var isLoading = true
    @State private var showUpgrade = false
    @State private var selectedTalk: TalkModel? = nil
    @State private var showDetail = false
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            ScrollView {
                VStack(alignment: .center, spacing: 48) {
                    // Title
                    Text("Talks List")
                        .font(.system(size: 48, weight: .bold))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                    if isLoading {
                        ProgressView("Loading Talks...")
                    } else if talks.isEmpty {
                        Text("No talks found.")
                            .foregroundColor(.secondary)
                    } else {
                        VStack(spacing: 32) {
                            ForEach(talks) { talk in
                                Button(action: {
                                    selectedTalk = talk
                                    showDetail = true
                                }) {
                                    HStack(alignment: .center, spacing: 20) {
                                        Image(systemName: "text.bubble")
                                            .foregroundColor(Color.blue)
                                            .frame(width: 40, height: 40)
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(talk.title)
                                                .font(.title2)
                                                .foregroundColor(.primary)
                                                .multilineTextAlignment(.leading)
                                            if let hazard = talk.hazard {
                                                let translatedHazard = Translations.translateHazard(hazard, language: selectedLanguage)
                                                Text(translatedHazard)
                                                    .font(.title3)
                                                    .foregroundColor(.gray)
                                            }
                                            if let industry = talk.industry {
                                                let translatedIndustry = Translations.translateIndustry(industry, language: selectedLanguage)
                                                Text(translatedIndustry)
                                                    .font(.title3)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(20)
                                    .shadow(color: Color(.systemGray4).opacity(0.2), radius: 6, x: 0, y: 2)
                                }
                            }
                        }
                        .padding(.horizontal, 80)
                        NavigationLink(
                            destination: selectedTalk.map { TalkDetailView(talk: $0) },
                            isActive: $showDetail
                        ) { EmptyView() }
                    }
                }
                .padding(.vertical, 60)
            }
            .onAppear {
                print("TalksListView appeared on iPad with filterType: \(filterType), filterValue: \(filterValue)")
                fetchTalks()
            }
        } else {
            VStack(spacing: 0) {
                if isLoading {
                    ProgressView("Loading Talks...")
                        .frame(maxHeight: .infinity)
                } else if talks.isEmpty {
                    Text("No talks found.")
                        .foregroundColor(.secondary)
                        .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(talks) { talk in
                                Button(action: {
                                    onTalkTap(talk)
                                }) {
                                    HStack(alignment: .center, spacing: 12) {
                                        Image(systemName: "text.bubble")
                                            .foregroundColor(Color.blue)
                                            .frame(width: 32, height: 32)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(talk.title)
                                                .font(.body)
                                                .foregroundColor(.primary)
                                                .multilineTextAlignment(.leading)
                                            if let hazard = talk.hazard {
                                                let translatedHazard = Translations.translateHazard(hazard, language: selectedLanguage)
                                                Text(translatedHazard)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                                    .onAppear {
                                                        print("Hazard: \(hazard) -> \(translatedHazard) (Language: \(selectedLanguage))")
                                                    }
                                            }
                                            if let industry = talk.industry {
                                                let translatedIndustry = Translations.translateIndustry(industry, language: selectedLanguage)
                                                Text(translatedIndustry)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                                    .onAppear {
                                                        print("Industry: \(industry) -> \(translatedIndustry) (Language: \(selectedLanguage))")
                                                    }
                                            }
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(16)
                                    .shadow(color: Color(.systemGray4).opacity(0.2), radius: 4, x: 0, y: 2)
                                }
                            }
                        }
                        .padding(.top, 24)
                        .padding(.horizontal)
                    }
                }
                Spacer()
                HStack {
                    Spacer()
                    NavigationLink(destination: UpgradePlanView(), isActive: $showUpgrade) { EmptyView() }
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
                    .padding(.trailing, 32)
                    .padding(.bottom, 24)
                }
            }
            .background(Color.white.ignoresSafeArea())
            .navigationTitle(filterType == .hazard ? 
                Translations.translateHazard(filterValue, language: selectedLanguage) :
                Translations.translateIndustry(filterValue, language: selectedLanguage))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                print("TalksListView appeared on iPhone with filterType: \(filterType), filterValue: \(filterValue)")
                print("Selected Language: \(selectedLanguage)")
                print("Filter Value: \(filterValue)")
                let translatedValue = filterType == .hazard ? 
                    Translations.translateHazard(filterValue, language: selectedLanguage) :
                    Translations.translateIndustry(filterValue, language: selectedLanguage)
                print("Translated Filter Value: \(translatedValue)")
                fetchTalks()
            }
        }
    }
    
    func fetchTalks() {
        isLoading = true
        let endpoint: String
        switch filterType {
        case .hazard:
            endpoint = "\(NetworkService.shared.baseURL)/talks/by_hazard/\(filterValue)?language=\(selectedLanguage)"
        case .industry:
            endpoint = "\(NetworkService.shared.baseURL)/talks/by_industry/\(filterValue)?language=\(selectedLanguage)"
        }
        print("Fetching talks from: \(endpoint)")
        guard let url = URL(string: endpoint.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            guard let data = data, error == nil else { return }
            if let talks = try? JSONDecoder().decode([TalkModel].self, from: data) {
                DispatchQueue.main.async {
                    print("Received \(talks.count) talks")
                    for talk in talks {
                        print("Talk: \(talk.title), Hazard: \(talk.hazard ?? "none"), Industry: \(talk.industry ?? "none")")
                    }
                    self.talks = talks
                }
            }
        }.resume()
    }
}

#Preview {
    TalksListView(filterType: .hazard, filterValue: "Fire", onTalkTap: { _ in })
} 

