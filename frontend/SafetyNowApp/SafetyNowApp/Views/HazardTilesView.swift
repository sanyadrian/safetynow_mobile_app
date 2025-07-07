import SwiftUI

struct HazardTilesView: View {
    @AppStorage("access_token") var accessToken: String = ""
    @AppStorage("selectedLanguage") var selectedLanguage: String = "en"
    @State private var hazards: [String] = []
    @State private var isLoading = true
    @State private var selectedHazard: String? = nil
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
    
    var sortedHazards: [String] {
        let translatedHazards = hazards.map { hazard in
            (original: hazard, translated: Translations.translateHazard(hazard, language: selectedLanguage))
        }
        
        let sorted = translatedHazards.sorted { first, second in
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
                Text("Hazards")
                    .font(.system(size: 48, weight: .bold))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 20)
                
                if isLoading {
                    ProgressView("Loading Hazards...")
                        .font(.title2)
                } else {
                    List(sortedHazards, id: \.self) { hazard in
                        Button(action: {
                            selectedHazard = hazard
                            showTalksList = true
                        }) {
                            HStack {
                                Text(Translations.translateHazard(hazard, language: selectedLanguage))
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
                    destination: selectedHazard.map { hazard in
                        TalksListView(
                            filterType: .hazard, 
                            filterValue: hazard, 
                            onTalkTap: { talk in onTalksTap(talk.title) },
                            onBack: {
                                selectedHazard = nil
                                showTalksList = false
                            },
                            showBackButton: false
                        )
                    },
                    isActive: $showTalksList
                ) { EmptyView() }
            }
            .padding(.vertical, 60)
            .onAppear(perform: fetchHazards)
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
                    ProgressView("Loading Hazards...")
                } else {
                    List(sortedHazards, id: \.self) { hazard in
                        Button(action: {
                            onTalksTap(hazard)
                        }) {
                            HStack {
                                Text(Translations.translateHazard(hazard, language: selectedLanguage))
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
            .navigationTitle(LocalizationManager.shared.localizedString(for: "findtalk.hazards"))
            .onAppear(perform: fetchHazards)
        }
    }
    
    func fetchHazards() {
        guard let url = URL(string: "\(NetworkService.shared.baseURL)/talks/hazards") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            guard let data = data, error == nil else { return }
            if let hazards = try? JSONDecoder().decode([String].self, from: data) {
                DispatchQueue.main.async {
                    self.hazards = hazards
                }
            }
        }.resume()
    }
}

#Preview {
    HazardTilesView(onTalksTap: { _ in }, onBack: {})
} 