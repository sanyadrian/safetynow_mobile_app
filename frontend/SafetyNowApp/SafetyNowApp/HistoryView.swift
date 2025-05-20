import SwiftUI

struct HistoryView: View {
    @AppStorage("access_token") var accessToken: String = ""
    @State private var history: [HistoryItem] = []
    @Binding var selectedTab: Tab

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
                                Image(systemName: "ellipsis")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(16)
                        }

                        Text("Most Popular")
                            .font(.headline)
                            .padding(.top)

                        // Placeholder static items
                        ForEach(samplePopular, id: \.self) { talk in
                            HStack {
                                Image(systemName: "doc.text.fill")
                                    .foregroundColor(.blue)
                                Text(talk)
                                    .font(.subheadline)
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
            // The BottomNavBar is outside the ScrollView in MainView, so nothing to add here
        }
        .onAppear {
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
        }
    }

    private var samplePopular: [String] {
        [
            "Help me find step-by-step tutorials on website building",
            "Make me a list of recommended children's books for my niece's birthday gift",
            "Search for online courses on web development and sign me up"
        ]
    }
}
