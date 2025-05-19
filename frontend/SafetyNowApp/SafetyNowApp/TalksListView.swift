import SwiftUI

enum TalkFilterType {
    case hazard
    case industry
}

struct TalkModel: Identifiable, Decodable {
    let id: Int
    let title: String
    let category: String
    let description: String?
    let hazard: String?
    let industry: String?
}

struct TalksListView: View {
    let filterType: TalkFilterType
    let filterValue: String
    @AppStorage("access_token") var accessToken: String = ""
    @State private var talks: [TalkModel] = []
    @State private var isLoading = true
    
    var body: some View {
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
                            HStack(alignment: .center, spacing: 12) {
                                Image(systemName: "text.bubble")
                                    .foregroundColor(Color.blue)
                                    .frame(width: 32, height: 32)
                                Text(talk.title)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                Button(action: {
                                    // Handle more action
                                }) {
                                    Image(systemName: "ellipsis")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                            .shadow(color: Color(.systemGray4).opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                    }
                    .padding(.top, 24)
                    .padding(.horizontal)
                }
            }
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    // Handle Access More action
                }) {
                    Text("ACCESS MORE")
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
        .navigationTitle(filterValue)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: fetchTalks)
    }
    
    func fetchTalks() {
        let endpoint: String
        switch filterType {
        case .hazard:
            endpoint = "http://localhost:8000/talks/by_hazard/\(filterValue)"
        case .industry:
            endpoint = "http://localhost:8000/talks/by_industry/\(filterValue)"
        }
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
                    self.talks = talks
                }
            }
        }.resume()
    }
}

#Preview {
    TalksListView(filterType: .hazard, filterValue: "Hazard A")
} 
