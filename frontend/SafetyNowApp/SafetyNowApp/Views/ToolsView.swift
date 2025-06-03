import SwiftUI

struct ToolsView: View {
    @AppStorage("access_token") var accessToken: String = ""
    @AppStorage("selectedLanguage") var selectedLanguage: String = "en"
    @State private var tools: [Tool] = []
    @State private var isLoading = true
    @State private var openToolModel: Tool? = nil

    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                ProgressView("Loading Tools...")
                    .frame(maxHeight: .infinity)
            } else if tools.isEmpty {
                Text("No tools found.")
                    .foregroundColor(.secondary)
                    .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(tools) { tool in
                            NavigationLink(destination: ToolDetailView(tool: tool)) {
                                HStack(alignment: .center, spacing: 12) {
                                    Image(systemName: "wrench.and.screwdriver")
                                        .foregroundColor(Color.blue)
                                        .frame(width: 32, height: 32)
                                    VStack(alignment: .leading) {
                                        Text(tool.title)
                                            .font(.body)
                                            .foregroundColor(.primary)
                                            .multilineTextAlignment(.leading)
                                    }
                                    Spacer()
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(16)
                                .shadow(color: Color(.systemGray4).opacity(0.2), radius: 4, x: 0, y: 2)
                            }
                        }
                    }
                    .padding(.top, 24)
                    .padding(.horizontal)
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("Tools")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            fetchTools()
        }
    }
    
    private func fetchTools() {
        isLoading = true
        let urlString = "http://localhost:8000/tools?language=\(selectedLanguage)"
        guard let url = URL(string: urlString) else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if let data = data {
                    do {
                        let tools = try JSONDecoder().decode([Tool].self, from: data)
                        self.tools = tools
                    } catch {
                        print("Decoding error: \(error)")
                    }
                }
            }
        }.resume()
    }
} 