import SwiftUI

struct IndustryTilesView: View {
    @AppStorage("access_token") var accessToken: String = ""
    @State private var industries: [String] = []
    @State private var isLoading = true
    @State private var selectedIndustry: String? = nil
    @State private var showTalks = false
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading Industries...")
            } else {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 20) {
                        ForEach(industries, id: \.self) { industry in
                            Button(action: {
                                selectedIndustry = industry
                                showTalks = true
                            }) {
                                Text(industry)
                                    .frame(maxWidth: .infinity, minHeight: 80)
                                    .background(Color.green.opacity(0.2))
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
        .navigationTitle("Industries")
        .onAppear(perform: fetchIndustries)
        .navigationDestination(isPresented: $showTalks) {
            if let industry = selectedIndustry {
                TalksListView(filterType: .industry, filterValue: industry)
            }
        }
    }
    
    func fetchIndustries() {
        guard let url = URL(string: "http://localhost:8000/talks/industries") else { return }
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
    IndustryTilesView()
} 