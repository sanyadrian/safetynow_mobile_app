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
                    Text("How to Share a Safety Talk")
                        .font(.title2)
                        .bold()
                }
                .padding(.top, 32)
                Text("You can easily share any Safety Talk with your team or contacts as a professional PDF:")
                    .font(.body)
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        Text("1.")
                            .bold()
                        Text("Open any Safety Talk from the app (for example, from History or Most Popular).")
                    }
                    HStack(alignment: .center, spacing: 4) {
                        Text("2.").bold()
                        Text("Tap the share icon")
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.blue)
                        Text(".")
                    }
                    HStack(alignment: .top) {
                        Text("3.")
                            .bold()
                        Text("Choose how you want to share: Messages, Email, AirDrop, WhatsApp, and more.")
                    }
                    HStack(alignment: .top) {
                        Text("4.")
                            .bold()
                        Text("A PDF with the talk's details and your company branding will be sent.")
                    }
                }
                .font(.body)
                .padding(.vertical)
                Text("Tip: You can also save the PDF to your Files or print it for in-person meetings.")
                    .font(.footnote)
                    .foregroundColor(.gray)
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Share a Talk")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

#Preview {
    ShareTalkInfoView()
} 