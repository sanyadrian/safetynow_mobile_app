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
    @State private var showDeleteAccountConfirmation = false
    @State private var showDeleteAccountPassword = false
    @State private var deleteAccountPassword = ""
    @State private var deleteAccountError = ""

    var body: some View {
        NavigationStack {
            Group {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    ScrollView {
                        VStack(alignment: .center, spacing: 48) {
                            // Title
                            Text("Profile")
                                .font(.system(size: 48, weight: .bold))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .center)
                            ZStack {
                                if let imageData = selectedImageData,
                                   let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 2))
                                } else if !profileImage.isEmpty,
                                          let profileImageUrl = URL(string: profileImage) {
                                    AsyncImage(url: profileImageUrl) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 120)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 2))
                                    } placeholder: {
                                        ProgressView()
                                            .frame(width: 120, height: 120)
                                    }
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .foregroundColor(.gray)
                                }
                                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                                    Circle().fill(Color.clear).frame(width: 120, height: 120)
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
                                .font(.title)
                                .bold()
                                .padding(.top, 8)
                            Text(email)
                                .font(.title3)
                                .foregroundColor(.gray)
                            HStack {
                                Text("Notification")
                                    .font(.title3)
                                Spacer()
                                Toggle("", isOn: $isNotificationsOn)
                                    .labelsHidden()
                            }
                            .padding(.horizontal, 80)
                            VStack(spacing: 32) {
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
                                Button(action: { showDeleteAccountConfirmation = true }) {
                                    HStack {
                                        Text("Delete Account")
                                            .font(.title3)
                                            .foregroundColor(.red)
                                        Spacer()
                                        ZStack {
                                            Circle()
                                                .fill(Color(.systemGray6))
                                                .frame(width: 40, height: 40)
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                                Button(action: logout) {
                                    HStack {
                                        Text(LocalizationManager.shared.localizedString(for: "button.logout"))
                                            .font(.title3)
                                            .foregroundColor(.red)
                                        Spacer()
                                        ZStack {
                                            Circle()
                                                .fill(Color(.systemGray6))
                                                .frame(width: 40, height: 40)
                                            Image(systemName: "arrow.right")
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 80)
                        }
                        .padding(.vertical, 60)
                    }
                } else {
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
                                      let profileImageUrl = URL(string: profileImage) {
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
                            Button(action: { showDeleteAccountConfirmation = true }) {
                                HStack {
                                    Text("Delete Account")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.red)
                                    Spacer()
                                    ZStack {
                                        Circle()
                                            .fill(Color(.systemGray6))
                                            .frame(width: 32, height: 32)
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
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
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showLanguage) {
                LanguageSelectionView()
            }
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
        .alert("Delete Account", isPresented: $showDeleteAccountConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                showDeleteAccountPassword = true
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone.")
        }
        .sheet(isPresented: $showDeleteAccountPassword) {
            NavigationStack {
                VStack(spacing: 20) {
                    Text("Enter your password to confirm account deletion")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.top)
                    
                    SecureField("Password", text: $deleteAccountPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    if !deleteAccountError.isEmpty {
                        Text(deleteAccountError)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    Button(action: deleteAccount) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Delete Account")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .disabled(isLoading)
                    
                    Spacer()
                }
                .navigationTitle("Confirm Deletion")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showDeleteAccountPassword = false
                            deleteAccountPassword = ""
                            deleteAccountError = ""
                        }
                    }
                }
            }
        }
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

    private func deleteAccount() {
        guard !deleteAccountPassword.isEmpty else {
            deleteAccountError = "Please enter your password"
            return
        }
        
        isLoading = true
        deleteAccountError = ""
        
        NetworkService.shared.deleteAccount(password: deleteAccountPassword, token: accessToken) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success:
                    // Clear all user data and log out
                    accessToken = ""
                    profileImage = ""
                    username = ""
                    email = ""
                    isLoggedIn = false
                    showDeleteAccountPassword = false
                case .failure(let error):
                    if let networkError = error as? NetworkError {
                        switch networkError {
                        case .backendMessage(let message):
                            deleteAccountError = message
                        default:
                            deleteAccountError = error.localizedDescription
                        }
                    } else {
                        deleteAccountError = error.localizedDescription
                    }
                }
            }
        }
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
