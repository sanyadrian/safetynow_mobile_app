import SwiftUI

struct DashboardView: View {
    @AppStorage("access_token") var accessToken: String = ""
    @AppStorage("username") var storedUsername: String = ""
    @State private var history: [HistoryItem] = []
    @Binding var selectedTab: Tab
    @State private var navigateToFindTalk = false
    @State private var showTicketSubmission = false
    @State private var showCalendar = false
    @State private var showMenu = false
    @State private var showSettings = false
    @State private var showLanguage = false
    @State private var showHelpCenter = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Button(action: {
                        // Clear all UserDefaults
                        if let bundleID = Bundle.main.bundleIdentifier {
                            UserDefaults.standard.removePersistentDomain(forName: bundleID)
                        }
                        // Force app restart
                        exit(0)
                    }) {
                        Text("RESET APP STATE")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)

                    HStack {
                        Button(action: { showMenu = true }) {
                            Image(systemName: "line.horizontal.3")
                        }
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

                    HStack(spacing: 16) {
                        actionTile(title: "Find a Talk", systemIcon: "text.bubble") {
                            selectedTab = .search
                        }
                        actionTile(title: "Talk to SafetyNow", systemIcon: "mic") {
                            showTicketSubmission = true
                        }
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
                }
                .padding(.top)
            }
            .sheet(isPresented: $showTicketSubmission) {
                TicketSubmissionView()
            }
            .sheet(isPresented: $showMenu) {
                VStack(spacing: 32) {
                    Spacer().frame(height: 32)
                    Text("Menu")
                        .font(.title2)
                        .bold()
                    VStack(spacing: 24) {
                        Button(action: { showSettings = true; showMenu = false }) {
                            menuRow(title: "Settings")
                        }
                        Button(action: { showLanguage = true; showMenu = false }) {
                            menuRow(title: "Language")
                        }
                        Button(action: { showHelpCenter = true; showMenu = false }) {
                            menuRow(title: "Help Center")
                        }
                    }
                    .padding(.horizontal)
                    Spacer()
                }
                .presentationDetents([.medium])
            }
            .background(
                NavigationLink(destination: SettingsView(), isActive: $showSettings) { EmptyView() }
                    .hidden()
            )
            .background(
                NavigationLink(destination: LanguageSelectionView(), isActive: $showLanguage) { EmptyView() }
                    .hidden()
            )
            .sheet(isPresented: $showHelpCenter) {
                TicketSubmissionView()
            }
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

    private func actionTile(title: String, systemIcon: String, action: @escaping () -> Void) -> some View {
        VStack {
            Button(action: action) {
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
                        .foregroundColor(.primary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }

    private func menuRow(title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            Spacer()
            ZStack {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 32, height: 32)
                Image(systemName: "arrow.right")
                    .foregroundColor(.blue)
            }
        }
    }
}
