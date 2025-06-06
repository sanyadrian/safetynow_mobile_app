import SwiftUI
import PhotosUI
import PDFKit

struct ProfileView: View {
    @AppStorage("access_token") var accessToken: String = ""
    @AppStorage("profile_image") var profileImage: String = ""
    @AppStorage("username") var username: String = ""
    @AppStorage("email") var email: String = ""
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = true
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isNotificationsOn = true
    @Binding var selectedTab: Tab
    @State private var showSettings = false
    @State private var showLanguage = false
    @State private var showHelpCenter = false
    @State private var showPrivacyPolicy = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 32)
            // Profile Image
            ZStack {
                if let imageData = selectedImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 2))
                } else if !profileImage.isEmpty,
                          let profileImageUrl = URL(string: "https://safetynow-app.com\(profileImage)") {
                    AsyncImage(url: profileImageUrl) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 2))
                    } placeholder: {
                        ProgressView()
                            .frame(width: 100, height: 100)
                    }
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.gray)
                }
                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                    Circle().fill(Color.clear).frame(width: 100, height: 100)
                }
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self) {
                            selectedImageData = data
                            uploadImage(data)
                        }
                    }
                }
            }
            Text(username)
                .font(.title3).bold()
                .padding(.top, 8)
            Text(email)
                .font(.subheadline)
                .foregroundColor(.gray)

            HStack {
                Text("Notification")
                    .font(.subheadline)
                Spacer()
                Toggle("", isOn: $isNotificationsOn)
                    .labelsHidden()
            }
            .padding(.horizontal)

            VStack(spacing: 24) {
                Button(action: { showSettings = true }) {
                    profileRow(title: LocalizationManager.shared.localizedString(for: "menu.settings"))
                }
                Button(action: { showLanguage = true }) {
                    profileRow(title: LocalizationManager.shared.localizedString(for: "menu.language"))
                }
                Button(action: { showHelpCenter = true }) {
                    profileRow(title: LocalizationManager.shared.localizedString(for: "menu.help_center"))
                }
                Button(action: { showPrivacyPolicy = true }) {
                    profileRow(title: "Privacy Policy")
                }
                Button(action: logout) {
                    HStack {
                        Text(LocalizationManager.shared.localizedString(for: "button.logout"))
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.red)
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray6))
                                .frame(width: 32, height: 32)
                            Image(systemName: "arrow.right")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .padding(.horizontal)

            NavigationLink(destination: SettingsView(), isActive: $showSettings) { EmptyView() }
            NavigationLink(destination: LanguageSelectionView(), isActive: $showLanguage) { EmptyView() }
            .sheet(isPresented: $showHelpCenter) {
                TicketSubmissionView()
            }
            .sheet(isPresented: $showPrivacyPolicy) {
                PDFKitView(url: Bundle.main.url(forResource: "PrivacyPolicy", withExtension: "pdf"))
            }

            if isLoading {
                ProgressView()
            }
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            Spacer()
        }
        .padding(.top)
    }

    private func profileRow(title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            Spacer()
            ZStack {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 32, height: 32)
                Image(systemName: "arrow.right")
                    .foregroundColor(.blue)
            }
        }
    }

    private func uploadImage(_ imageData: Data) {
        isLoading = true
        errorMessage = nil
        NetworkService.shared.uploadProfileImage(image: imageData, token: accessToken) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let imagePath):
                    profileImage = imagePath
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func logout() {
        accessToken = ""
        profileImage = ""
        username = ""
        email = ""
        isLoggedIn = false
    }
}

struct PDFKitView: UIViewRepresentable {
    let url: URL?
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        if let url = url {
            pdfView.document = PDFDocument(url: url)
        }
        return pdfView
    }
    func updateUIView(_ uiView: PDFView, context: Context) {}
}
