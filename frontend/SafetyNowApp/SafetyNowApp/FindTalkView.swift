import SwiftUI

struct FindTalkView: View {
    let categories = [
        ("Hazards", "Search for a safety talk by workplace hazard.", "pencil"),
        ("Industry", "Search for a safety talk by Industry.", "pencil"),
        ("Send a Talk", "Send a safety talk to employees.", "calendar"),
        ("Translate", "Get a translated safety talk.", "globe"),
        ("Tools", "Access games, checklists, and other safety tools.", "lightbulb"),
        ("Calendar", "We’ve already built your annual safety training plan, just click and go.", "doc.on.doc")
    ]

    @Environment(\.dismiss) var dismiss
    @Binding var selectedTab: Tab

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Explore")
                    .font(.title)
                    .bold()
                    .padding(.top)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(categories.indices, id: \.self) { index in
                        let category = categories[index]
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: category.2)
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            Text(category.0)
                                .font(.headline)
                                .foregroundColor(.blue)
                            Text(category.1)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(20)
                    }
                }

                Spacer()

                Button(action: {
                    // Handle Access More action
                }) {
                    Text("ACCESS MORE")
                        .font(.footnote)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(20)
                }
                .padding(.top, 16)
            }
            .padding(.horizontal)
        }
    }
}
