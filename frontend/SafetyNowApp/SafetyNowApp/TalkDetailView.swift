import SwiftUI

struct TalkDetailView: View {
    let talk: TalkModel
    var onBack: (() -> Void)? = nil
    @AppStorage("access_token") var accessToken: String = ""

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Button(action: { onBack?() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.black)
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
                            Button(action: {}) {
                                Image(systemName: "hand.thumbsup")
                                    .foregroundColor(.blue)
                            }
                            Button(action: {}) {
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
        }
    }
}

#Preview {
    TalkDetailView(talk: TalkModel(id: 1, title: "Title of Safety Talks", category: "", description: "UI/UX design refers to the process of creating user interfaces (UI) and user experiences (UX) for digital products, such as websites, mobile apps, and software applications.\n\nUI design focuses on the visual elements and layout of a digital product, including components like buttons, icons, typography, color schemes, and overall aesthetics. The goal of UI design is to create an intuitive and visually appealing interface that users can interact with easily.\n\nOn the other hand, UX design is concerned with the overall experience that a user has while interacting with a digital product. It involves understanding user behaviors, preferences, and needs, and designing the product in a way that provides a seamless and satisfying experience. This includes aspects like user research, wireframing, prototyping, and testing to ensure that the product meets user", hazard: nil, industry: nil))
}
