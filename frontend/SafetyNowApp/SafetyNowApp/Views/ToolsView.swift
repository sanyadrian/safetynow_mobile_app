import SwiftUI

struct ToolsView: View {
    @AppStorage("access_token") var accessToken: String = ""
    @AppStorage("selectedLanguage") var selectedLanguage: String = "en"
    @State private var tools: [Tool] = []
    @State private var isLoading = true
    @State private var openToolModel: Tool? = nil

    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            ScrollView {
                VStack(alignment: .center, spacing: 48) {
                    // Title
                    Text("Tools")
                        .font(.system(size: 48, weight: .bold))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                    // ... rest of the content, centered and spaced, with .padding(.horizontal, 80) and .padding(.vertical, 60) ...
                }
                .padding(.vertical, 60)
            }
        } else {
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
                                Button(action: {
                                    openToolModel = tool
                                }) {
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
                                .buttonStyle(PlainButtonStyle())
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
            .background(
                NavigationLink(destination: openToolModel.map { ToolDetailView(tool: $0) }, isActive: Binding(get: { openToolModel != nil }, set: { if !$0 { openToolModel = nil } })) { EmptyView() }
            )
        }
    }
    
    private func fetchTools() {
        isLoading = true
        let urlString = "\(NetworkService.shared.baseURL)/tools?language=\(selectedLanguage)"
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