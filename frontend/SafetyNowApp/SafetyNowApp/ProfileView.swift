import SwiftUI
import PhotosUI

struct ProfileView: View {
    @AppStorage("access_token") var accessToken: String = ""
    @AppStorage("profile_image") var profileImage: String = ""
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var showingImagePicker = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Binding var selectedTab: Tab

    var body: some View {
        VStack {
            // Profile Image
            if let imageData = selectedImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
            } else if let profileImageUrl = URL(string: "http://192.168.4.25:8000\(profileImage)") {
                AsyncImage(url: profileImageUrl) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                } placeholder: {
                    ProgressView()
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.gray)
            }

            PhotosPicker(selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()) {
                Text("Change Photo")
                    .foregroundColor(.blue)
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                        uploadImage(data)
                    }
                }
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
        .padding()
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
