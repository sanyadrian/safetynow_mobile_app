import SwiftUI

struct ShareTalkInfoView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.blue)
                    Text(LocalizationManager.shared.localizedString(for: "shareinfo.title"))
                        .font(.title2)
                        .bold()
                }
                .padding(.top, 32)
                Text(LocalizationManager.shared.localizedString(for: "shareinfo.intro"))
                    .font(.body)
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        Text("1.")
                            .bold()
                        Text(LocalizationManager.shared.localizedString(for: "shareinfo.step1"))
                    }
                    HStack(alignment: .center, spacing: 4) {
                        Text("2.").bold()
                        Text(LocalizationManager.shared.localizedString(for: "shareinfo.step2"))
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.blue)
                        Text(".")
                    }
                    HStack(alignment: .top) {
                        Text("3.")
                            .bold()
                        Text(LocalizationManager.shared.localizedString(for: "shareinfo.step3"))
                    }
                    HStack(alignment: .top) {
                        Text("4.")
                            .bold()
                        Text(LocalizationManager.shared.localizedString(for: "shareinfo.step4"))
                    }
                }
                .font(.body)
                .padding(.vertical)
                Text(LocalizationManager.shared.localizedString(for: "shareinfo.tip"))
                    .font(.footnote)
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding()
        }
        .navigationTitle(LocalizationManager.shared.localizedString(for: "shareinfo.nav_title"))
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

#Preview {
    ShareTalkInfoView()
} 