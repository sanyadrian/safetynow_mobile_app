import SwiftUI
import PhotosUI

struct ProfileView: View {
    @AppStorage("access_token") var accessToken: String = ""
    @AppStorage("profile_image") var profileImage: String = ""
    @AppStorage("username") var username: String = ""
    @AppStorage("email") var email: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var isNotificationsOn = true
    @Binding var selectedTab: Tab
    @State private var showSettings = false
    @State private var showLanguage = false
    @State private var showHelpCenter = false

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
                } else if let profileImageUrl = URL(string: "http://192.168.4.25:8000\(profileImage)") {
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
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 100, height: 100)
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
                    profileRow(title: "Settings")
                }
                Button(action: { showLanguage = true }) {
                    profileRow(title: "Language")
                }
                Button(action: { showHelpCenter = true }) {
                    profileRow(title: "Help Center")
                }
            }
            .padding(.horizontal)

            NavigationLink(destination: SettingsView(), isActive: $showSettings) { EmptyView() }
            NavigationLink(destination: LanguageSelectionView(), isActive: $showLanguage) { EmptyView() }
            .sheet(isPresented: $showHelpCenter) {
                TicketSubmissionView()
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
}
