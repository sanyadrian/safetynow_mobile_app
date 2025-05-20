import SwiftUI

struct LanguageSelectionView: View {
    @AppStorage("language") private var language: String = "English"
    let languages = ["English", "Spanish", "French"]

    var body: some View {
        VStack(spacing: 24) {
            Text("Select Language")
                .font(.title)
                .bold()
                .padding(.top, 32)

            List {
                ForEach(languages, id: \.self) { lang in
                    HStack {
                        Text(lang)
                        Spacer()
                        if lang == language {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        language = lang
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())

            Spacer()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

#Preview {
    LanguageSelectionView()
} 