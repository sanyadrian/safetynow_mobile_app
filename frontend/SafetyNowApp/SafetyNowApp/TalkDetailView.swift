import SwiftUI

struct TalkDetailView: View {
    let talk: TalkModel
    var onBack: (() -> Void)? = nil
    @AppStorage("access_token") var accessToken: String = ""
    @State private var likeCount: Int = 0
    @State private var isLiked: Bool = false
    @State private var isLoading: Bool = false
    @State private var showShareSheet = false
    @State private var shareContent: [Any] = []

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                if let onBack = onBack {
                    Button(action: { onBack() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                }
                Spacer()
                Text("Safety Talk")
                    .font(.title2)
                    .bold()
                Spacer()
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.title2)
                        .foregroundColor(.black)
                }
            }
            .padding([.horizontal, .top])

            // Talk title with icon
            HStack(spacing: 8) {
                Image(systemName: "doc.text")
                    .foregroundColor(.black)
                Text(talk.title)
                    .font(.headline)
                    .bold()
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 24)

            // Talk description/content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(talk.description ?? "")
                        .font(.body)
                        .foregroundColor(.black)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color(.systemGray4).opacity(0.1), radius: 2, x: 0, y: 1)
                    HStack(spacing: 16) {
                            Button(action: {
                                toggleLike()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: isLiked ? "hand.thumbsup.fill" : "hand.thumbsup")
                                        .foregroundColor(isLiked ? .blue : .gray)
                                    if likeCount > 0 {
                                        Text("\(likeCount)")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                            .disabled(isLoading)
                            Button(action: {
                                if let pdfURL = createPDF(for: talk.title, description: talk.description) {
                                    shareContent = [pdfURL]
                                    showShareSheet = true
                                }
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(.blue)
                            }
                            Button(action: {}) {
                                Image(systemName: "ellipsis")
                                    .foregroundColor(.blue)
                            }
                            Spacer()
                            Button(action: {}) {
                                Text("ACCESS MORE")
                                    .font(.footnote)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.blue)
                                    .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                    }
                    .padding([.horizontal, .top])
                }

                Spacer()
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            NetworkService.shared.addToHistory(token: accessToken, talkTitle: talk.title) { result in
                switch result {
                case .success:
                    print("Successfully added talk to history")
                case .failure(let error):
                    print("Failed to add talk to history: \(error.localizedDescription)")
                }
            }
            
            fetchLikeStatus()
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: shareContent)
        }
    }
    
    private func fetchLikeStatus() {
        guard let url = URL(string: "http://localhost:8000/talks/\(talk.id)/likes") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data,
               let likeInfo = try? JSONDecoder().decode(LikeInfo.self, from: data) {
                DispatchQueue.main.async {
                    self.likeCount = likeInfo.likeCount
                    self.isLiked = likeInfo.userLiked
                }
            }
        }.resume()
    }
    
    private func toggleLike() {
        isLoading = true
        guard let url = URL(string: "http://localhost:8000/talks/\(talk.id)/like") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                if error == nil {
                    isLiked.toggle()
                    likeCount += isLiked ? 1 : -1
                }
            }
        }.resume()
    }
}

struct LikeInfo: Decodable {
    let likeCount: Int
    let userLiked: Bool
    
    enum CodingKeys: String, CodingKey {
        case likeCount = "like_count"
        case userLiked = "user_liked"
    }
}

#Preview {
    TalkDetailView(talk: TalkModel(id: 1, title: "Title of Safety Talks", category: "", description: "UI/UX design refers to the process of creating user interfaces (UI) and user experiences (UX) for digital products, such as websites, mobile apps, and software applications.\n\nUI design focuses on the visual elements and layout of a digital product, including components like buttons, icons, typography, color schemes, and overall aesthetics. The goal of UI design is to create an intuitive and visually appealing interface that users can interact with easily.\n\nOn the other hand, UX design is concerned with the overall experience that a user has while interacting with a digital product. It involves understanding user behaviors, preferences, and needs, and designing the product in a way that provides a seamless and satisfying experience. This includes aspects like user research, wireframing, prototyping, and testing to ensure that the product meets user", hazard: nil, industry: nil))
}
