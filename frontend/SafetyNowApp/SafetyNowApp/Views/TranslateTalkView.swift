import SwiftUI

struct TranslateTalkView: View {
    @AppStorage("access_token") var accessToken: String = ""
    @State private var talks: [TalkModel] = []
    @State private var isLoading = true
    @State private var selectedTalk: TalkModel? = nil
    @State private var selectedLanguage: String = "English"
    @State private var showTranslation = false
    let languages = ["English", "Spanish", "French"]

    var body: some View {
        VStack(spacing: 0) {
            Text("Translate a Safety Talk")
                .font(.title2)
                .bold()
                .padding(.top, 24)

            if selectedTalk == nil {
                if isLoading {
                    ProgressView("Loading Talks...")
                        .frame(maxHeight: .infinity)
                } else {
                    List(talks) { talk in
                        Button(action: {
                            selectedTalk = talk
                        }) {
                            VStack(alignment: .leading) {
                                Text(talk.title)
                                    .font(.headline)
                                if let desc = talk.description {
                                    Text(desc)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                }
            } else if !showTranslation {
                VStack(spacing: 24) {
                    Text("Select Language")
                        .font(.headline)
                    Picker("Language", selection: $selectedLanguage) {
                        ForEach(languages, id: \.self) { lang in
                            Text(lang)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    Button(action: { showTranslation = true }) {
                        Text(LocalizationManager.shared.localizedString(for: "button.translate"))
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    Button(LocalizationManager.shared.localizedString(for: "button.back")) { selectedTalk = nil }
                        .foregroundColor(.red)
                }
                .padding()
            } else if let talk = selectedTalk {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Translated Talk (") + Text(selectedLanguage).bold() + Text(")")
                        .font(.headline)
                    Text(mockTranslate(talk.title, to: selectedLanguage))
                        .font(.title3)
                        .bold()
                    Text(mockTranslate(talk.description ?? "", to: selectedLanguage))
                        .font(.body)
                        .foregroundColor(.gray)
                    Button(LocalizationManager.shared.localizedString(for: "button.back")) {
                        showTranslation = false
                    }
                    .foregroundColor(.red)
                }
                .padding()
            }
            Spacer()
        }
        .onAppear(perform: fetchTalks)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    func fetchTalks() {
        isLoading = true
        let endpoint = "\(NetworkService.shared.baseURL)/talks/"
        guard let url = URL(string: endpoint) else { return }
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
                    self.talks = talks
                }
            }
        }.resume()
    }

    func mockTranslate(_ text: String, to language: String) -> String {
        switch language {
        case "Spanish": return "[ES] " + text
        case "French": return "[FR] " + text
        default: return text
        }
    }
}

#Preview {
    TranslateTalkView()
} 