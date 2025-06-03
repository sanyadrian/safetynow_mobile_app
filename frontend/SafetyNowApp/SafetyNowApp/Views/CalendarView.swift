import SwiftUI

class CalendarViewModel: ObservableObject {
    @Published var allTalks: [TalkModel] = [] {
        didSet {
            debugPrint("allTalks changed. New count: \(allTalks.count)")
        }
    }
    
    func fetchTalks(token: String, language: String) {
        debugPrint("Fetching talks with token: \(token.isEmpty ? "empty" : "present")")
        debugPrint("Selected language: \(language)")
        
        NetworkService.shared.getTalks(token: token, language: language) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let talks):
                    debugPrint("Successfully fetched \(talks.count) talks")
                    self?.allTalks = talks
                    debugPrint("Updated allTalks with \(self?.allTalks.count ?? 0) talks")
                case .failure(let error):
                    debugPrint("Failed to fetch talks: \(error)")
                }
            }
        }
    }
}

struct CalendarView: View {
    @AppStorage("access_token") var accessToken: String = ""
    @AppStorage("selectedLanguage") var selectedLanguage: String = "en"
    @StateObject private var viewModel = CalendarViewModel()
    @State private var showTalksForMonth: String? = nil

    let monthToTalkIDs: [String: [String: [Int]]] = [
        "en": [
            "January": [1],
            "February": [4],
        
        ],
        "fr": [
            "January": [2],
            "February": [5],
            
        ],
        "es": [
            "January": [3],
            "February": [6],
            
        ]
    ]

    
    let localizedMonths: [String: [String: String]] = [
        "en": [
            "January": "January",
            "February": "February"
        ],
        "fr": [
            "January": "Janvier",
            "February": "Février"
        ],
        "es": [
            "January": "Enero",
            "February": "Febrero"
        ]
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer().frame(height: 24)
                Text(NSLocalizedString("Calendar", comment: ""))
                    .font(.title)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)

                HStack(spacing: 24) {
                    monthCard(month: "January")
                        .onTapGesture { handleMonthTap("January") }
                    monthCard(month: "February")
                        .onTapGesture { handleMonthTap("February") }
                    // Add more months as needed
                }
                .padding(.horizontal)

                Spacer()
            }
            .background(Color.white.ignoresSafeArea())
            .onAppear { handleViewAppear() }
            .navigationDestination(item: $showTalksForMonth) { month in
                MonthTalksListView(
                    month: localizedMonths[selectedLanguage]?[month] ?? month,
                    talks: assignedTalks(for: month)
                )
            }
        }
    }

    private func handleMonthTap(_ month: String) {
        debugPrint("\(month) tapped. Current talks count: \(viewModel.allTalks.count)")
        showTalksForMonth = month
    }

    private func handleViewAppear() {
        debugPrint("CalendarView appeared")
        viewModel.fetchTalks(token: accessToken, language: selectedLanguage)
    }

    private func assignedTalks(for month: String) -> [TalkModel] {
        let languageTalks = monthToTalkIDs[selectedLanguage] ?? [:]
        let assignedIDs = languageTalks[month] ?? []
        let talks = viewModel.allTalks.filter { assignedIDs.contains($0.id) }
        debugPrint("Language: \(selectedLanguage)")
        debugPrint("Assigned IDs for \(month): \(assignedIDs)")
        debugPrint("All talks: \(viewModel.allTalks.map { $0.id })")
        debugPrint("Assigned talks: \(talks.map { $0.title })")
        return talks
    }

    private func monthCard(month: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "pencil")
                    .foregroundColor(.black)
                Spacer()
            }
            Text(localizedMonths[selectedLanguage]?[month] ?? month)
                .font(.headline)
                .foregroundColor(Color.blue)
                .fontWeight(.bold)
            Text(NSLocalizedString("Search for a safety talk by workplace hazard.", comment: ""))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(width: 150, height: 150)
        .background(Color.white)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

#Preview {
    CalendarView()
} 