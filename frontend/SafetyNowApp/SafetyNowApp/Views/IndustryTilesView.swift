import SwiftUI

struct IndustryTilesView: View {
    @AppStorage("access_token") var accessToken: String = ""
    @AppStorage("selectedLanguage") var selectedLanguage: String = "en"
    @State private var industries: [String] = []
    @State private var isLoading = true
    @State private var selectedIndustry: String? = nil
    @State private var showTalksList = false
    @State private var sortOrder: SortOrder = .ascending
    let onTalksTap: (String) -> Void
    let onBack: () -> Void
    
    enum SortOrder {
        case ascending, descending
        
        var icon: String {
            switch self {
            case .ascending: return "arrow.up.arrow.down"
            case .descending: return "arrow.down.arrow.up"
            }
        }
    }
    
    var sortedIndustries: [String] {
        let translatedIndustries = industries.map { industry in
            (original: industry, translated: Translations.translateIndustry(industry, language: selectedLanguage))
        }
        
        let sorted = translatedIndustries.sorted { first, second in
            let comparison = first.translated.localizedCaseInsensitiveCompare(second.translated)
            return sortOrder == .ascending ? comparison == .orderedAscending : comparison == .orderedDescending
        }
        
        return sorted.map { $0.original }
    }
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            VStack {
                // Header with back button and sort button
                HStack {
                    Button(action: onBack) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.blue)
                        .font(.title2)
                    }
                    Spacer()
                    
                    Button(action: {
                        sortOrder = sortOrder == .ascending ? .descending : .ascending
                    }) {
                        HStack {
                            Image(systemName: sortOrder.icon)
                            Text(sortOrder == .ascending ? "A-Z" : "Z-A")
                        }
                        .foregroundColor(.blue)
                        .font(.title2)
                    }
                }
                .padding(.horizontal, 80)
                .padding(.top)
                
                // Title
                Text("Industries")
                    .font(.system(size: 48, weight: .bold))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 20)
                
                if isLoading {
                    ProgressView("Loading Industries...")
                        .font(.title2)
                } else {
                    List(sortedIndustries, id: \.self) { industry in
                        Button(action: {
                            selectedIndustry = industry
                            showTalksList = true
                        }) {
                            HStack {
                                Text(Translations.translateIndustry(industry, language: selectedLanguage))
                                    .font(.title2)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.visible)
                    }
                    .listStyle(PlainListStyle())
                    .frame(maxWidth: 600)
                }
                
                NavigationLink(
                    destination: selectedIndustry.map { industry in
                        TalksListView(
                            filterType: .industry, 
                            filterValue: industry, 
                            onTalkTap: { talk in onTalksTap(talk.title) },
                            onBack: {
                                selectedIndustry = nil
                                showTalksList = false
                            },
                            showBackButton: false
                        )
                    },
                    isActive: $showTalksList
                ) { EmptyView() }
            }
            .padding(.vertical, 60)
            .onAppear(perform: fetchIndustries)
        } else {
            VStack {
                // Header with back button and sort button for iPhone
                HStack {
                    Button(action: onBack) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(.blue)
                        .font(.headline)
                    }
                    Spacer()
                    
                    Button(action: {
                        sortOrder = sortOrder == .ascending ? .descending : .ascending
                    }) {
                        HStack {
                            Image(systemName: sortOrder.icon)
                            Text(sortOrder == .ascending ? "A-Z" : "Z-A")
                        }
                        .foregroundColor(.blue)
                        .font(.headline)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                if isLoading {
                    ProgressView("Loading Industries...")
                } else {
                    List(sortedIndustries, id: \.self) { industry in
                        Button(action: {
                            onTalksTap(industry)
                        }) {
                            HStack {
                                Text(Translations.translateIndustry(industry, language: selectedLanguage))
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.visible)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle(LocalizationManager.shared.localizedString(for: "findtalk.industry"))
            .onAppear(perform: fetchIndustries)
        }
    }
    
    func fetchIndustries() {
        guard let url = URL(string: "\(NetworkService.shared.baseURL)/talks/industries") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            guard let data = data, error == nil else { return }
            if let industries = try? JSONDecoder().decode([String].self, from: data) {
                DispatchQueue.main.async {
                    self.industries = industries
                }
            }
        }.resume()
    }
}

#Preview {
    IndustryTilesView(onTalksTap: { _ in }, onBack: {})
} 