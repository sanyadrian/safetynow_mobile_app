import SwiftUI

struct FindTalkView: View {
    let categories = [
        ("Hazards", "Search for a safety talk by workplace hazard.", "pencil"),
        ("Industry", "Search for a safety talk by Industry.", "pencil"),
        ("Send a Talk", "Send a safety talk to employees.", "calendar"),
        ("Translate", "Get a translated safety talk.", "globe"),
        ("Tools", "Access games, checklists, and other safety tools.", "lightbulb"),
        ("Calendar", "We've already built your annual safety training plan, just click and go.", "doc.on.doc")
    ]

    @Environment(\.dismiss) var dismiss
    @Binding var selectedTab: Tab
    let onHazardTap: () -> Void
    let onIndustryTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Explore")
                .font(.title)
                .bold()
                .padding(.top)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(categories.indices, id: \.self) { index in
                    let category = categories[index]
                    if category.0 == "Hazards" {
                        Button(action: onHazardTap) {
                            tileView(category: category)
                        }
                    } else if category.0 == "Industry" {
                        Button(action: onIndustryTap) {
                            tileView(category: category)
                        }
                    } else {
                        tileView(category: category)
                    }
                }
            }

            HStack {
                Spacer()
                Button(action: {
                    // Handle Access More action
                }) {
                    Text("ACCESS MORE")
                        .font(.footnote)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color(red: 59/255, green: 89/255, blue: 255/255))
                        .cornerRadius(20)
                }
            }
            .padding(.trailing, 8)

            Spacer()
        }
        .padding(.horizontal)
    }

    private func tileView(category: (String, String, String)) -> some View {
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
