import SwiftUI

struct DashboardView: View {
    @AppStorage("access_token") var accessToken: String = ""
    @State private var history: [HistoryItem] = []
    @AppStorage("username") var storedUsername: String = ""
    @State private var showFindTalk = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // HEADER
                HStack {
                    Image(systemName: "line.horizontal.3")
                    Spacer()
                    VStack(alignment: .center) {
                        Text("Welcome Back")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("\(storedUsername)")
                            .font(.headline)
                            .bold()
                    }
                    Spacer()
                    Image(systemName: "bell")
                }
                .padding(.horizontal)

                // ACTION TILES
                HStack(spacing: 16) {
                    NavigationLink(destination: FindTalkView(), isActive: $showFindTalk) {
                        actionTile(title: "Find a Talk", systemIcon: "text.bubble")
                            .onTapGesture {
                                showFindTalk = true
                            }
                    }
                    actionTile(title: "Talk to SafetyNow", systemIcon: "mic")
                }
                .padding(.horizontal)

                // PROMO BOX
                VStack(alignment: .leading, spacing: 4) {
                    Text("SafetyNow ILT")
                        .foregroundColor(.blue)
                        .bold()
                    Text("Gain access to essential features")
                        .foregroundColor(.gray)
                    Text("Unlock Videos, Tools & eLearning")
                        .font(.footnote)
                        .foregroundColor(.blue)
                        .underline()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)

                // HISTORY
                VStack(alignment: .leading, spacing: 8) {
                    Text("History")
                        .font(.title3)
                        .bold()
                    ForEach(history) { item in
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.blue)
                            VStack(alignment: .leading) {
                                Text(item.talk_title)
                                    .font(.body)
                            }
                            Spacer()
                            Image(systemName: "ellipsis")
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)

                Spacer()

                // TAB BAR
                HStack {
                    Image(systemName: "house.fill")
                    Spacer()
                    Image(systemName: "magnifyingglass")
                    Spacer()
                    Image(systemName: "arrow.clockwise")
                    Spacer()
                    Image(systemName: "person.crop.circle")
                }
                .padding()
                .background(Color.white)
                .shadow(radius: 2)
            }
            .padding(.top)
            .onAppear {
                NetworkService.shared.getHistory(token: accessToken) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let items):
                            self.history = items
                        case .failure(let error):
                            print("\(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }

    private func actionTile(title: String, systemIcon: String) -> some View {
        VStack {
            Image(systemName: systemIcon)
                .resizable()
                .scaledToFit()
                .frame(height: 40)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            Text(title)
                .font(.footnote)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}
