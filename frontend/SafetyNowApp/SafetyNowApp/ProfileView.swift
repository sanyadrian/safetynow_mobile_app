import SwiftUI
import PhotosUI

struct ProfileView: View {
    @AppStorage("username") var username: String = ""
    @AppStorage("email") var email: String = ""
    @AppStorage("profile_image_url") var profileImageURL: String = ""

    @State private var isNotificationsOn = true
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var profileImage: Image? = nil
    @State private var imageData: Data? = nil
    @Binding var selectedTab: Tab

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                // Image Picker UI
                VStack {
                    if let image = profileImage {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .overlay(Text("Tap to add photo").font(.caption))
                    }

                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        Text("Choose Photo")
                            .foregroundColor(.blue)
                    }
                }
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            imageData = data
                            profileImage = Image(uiImage: uiImage)

                            if let token = UserDefaults.standard.string(forKey: "access_token") {
                                NetworkService.shared.uploadProfileImage(token: token, imageData: data) { result in
                                    switch result {
                                    case .success(let imagePath):
                                        DispatchQueue.main.async {
                                            profileImageURL = "\(NetworkService.shared.baseURL)/\(imagePath)"
                                        }
                                    case .failure(let error):
                                        print("Upload failed: \(error.localizedDescription)")
                                    }
                                }
                            }
                        }
                    }
                }

                // Name & Email
                Text(username)
                    .font(.headline)
                Text(email)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            HStack {
                Text("Notification")
                    .font(.subheadline)
                Spacer()
                Toggle("", isOn: $isNotificationsOn)
                    .labelsHidden()
            }
            .padding(.horizontal)

            // Menu Items
            VStack(spacing: 24) {
                profileRow(title: "Settings")
                profileRow(title: "Language")
                profileRow(title: "Security")
                profileRow(title: "Help Center")
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top)
        .onAppear {
            loadProfileImage()
        }
    }

    private func loadProfileImage() {
        guard let url = URL(string: profileImageURL), !profileImageURL.isEmpty else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data, let uiImage = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.profileImage = Image(uiImage: uiImage)
                }
            }
        }.resume()
    }

    private func profileRow(title: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Image(systemName: "arrow.right")
                .foregroundColor(.blue)
                .padding(8)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 1)
        }
    }
}
