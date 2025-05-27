import SwiftUI

struct LanguageSelectionView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage: String = "en"
    let languages = [("English", "en"), ("Spanish", "es"), ("French", "fr")]

    var body: some View {
        VStack(spacing: 24) {
            Text("Select Language")
                .font(.title)
                .bold()
                .padding(.top, 32)

            List {
                ForEach(languages, id: \ .1) { (langName, langCode) in
                    HStack {
                        Text(langName)
                        Spacer()
                        if langCode == selectedLanguage {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedLanguage = langCode
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