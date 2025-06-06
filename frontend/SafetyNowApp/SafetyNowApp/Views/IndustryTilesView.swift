import SwiftUI

struct IndustryTilesView: View {
    @AppStorage("access_token") var accessToken: String = ""
    @AppStorage("selectedLanguage") var selectedLanguage: String = "en"
    @State private var industries: [String] = []
    @State private var isLoading = true
    @State private var selectedIndustry: String? = nil
    let onTalksTap: (String) -> Void
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading Industries...")
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 20) {
                        ForEach(industries, id: \.self) { industry in
                            Button(action: {
                                onTalksTap(industry)
                            }) {
                                Text(Translations.translateIndustry(industry, language: selectedLanguage))
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
        .navigationTitle(LocalizationManager.shared.localizedString(for: "findtalk.industry"))
        .onAppear(perform: fetchIndustries)
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
    IndustryTilesView(onTalksTap: { _ in })
} 