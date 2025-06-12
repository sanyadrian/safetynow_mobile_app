import SwiftUI

struct HazardTilesView: View {
    @AppStorage("access_token") var accessToken: String = ""
    @AppStorage("selectedLanguage") var selectedLanguage: String = "en"
    @State private var hazards: [String] = []
    @State private var isLoading = true
    @State private var selectedHazard: String? = nil
    @State private var showTalksList = false
    let onTalksTap: (String) -> Void
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            ScrollView {
                VStack(alignment: .center, spacing: 48) {
                    // Title
                    Text("Hazards")
                        .font(.system(size: 48, weight: .bold))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                    if isLoading {
                        ProgressView("Loading Hazards...")
                    } else {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 180))], spacing: 32) {
                            ForEach(hazards, id: \.self) { hazard in
                                Button(action: {
                                    selectedHazard = hazard
                                    showTalksList = true
                                }) {
                                    Text(Translations.translateHazard(hazard, language: selectedLanguage))
                                        .frame(maxWidth: .infinity, minHeight: 100)
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(16)
                                        .foregroundColor(.primary)
                                        .font(.title2)
                                }
                            }
                        }
                        .padding(.horizontal, 80)
                    }
                    NavigationLink(
                        destination: selectedHazard.map { hazard in
                            TalksListView(filterType: .hazard, filterValue: hazard, onTalkTap: { talk in onTalksTap(talk.title) })
                        },
                        isActive: $showTalksList
                    ) { EmptyView() }
                }
                .padding(.vertical, 60)
            }
            .onAppear(perform: fetchHazards)
        } else {
            VStack {
                if isLoading {
                    ProgressView("Loading Hazards...")
                } else {
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 20) {
                            ForEach(hazards, id: \.self) { hazard in
                                Button(action: {
                                    onTalksTap(hazard)
                                }) {
                                    Text(Translations.translateHazard(hazard, language: selectedLanguage))
                                        .frame(maxWidth: .infinity, minHeight: 80)
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(12)
                                        .foregroundColor(.primary)
                                        .font(.headline)
                                }
                            }
                        }
                        .padding()
                    }
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
    HazardTilesView(onTalksTap: { _ in })
} 