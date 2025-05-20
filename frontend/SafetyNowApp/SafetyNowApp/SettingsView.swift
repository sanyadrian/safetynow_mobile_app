import SwiftUI

struct SettingsView: View {
    @AppStorage("username") var username: String = ""
    @AppStorage("email") var email: String = ""
    @State private var newUsername: String = ""
    @State private var newEmail: String = ""
    @State private var newPassword: String = ""
    @State private var showSaved = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Settings")
                .font(.title)
                .bold()
                .padding(.top, 32)

            VStack(alignment: .leading, spacing: 16) {
                Text("Username")
                    .font(.headline)
                TextField("Username", text: $newUsername)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Text("Email")
                    .font(.headline)
                TextField("Email", text: $newEmail)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)

                Text("Password")
                    .font(.headline)
                SecureField("New Password", text: $newPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding(.horizontal)

            Button(action: saveChanges) {
                Text("Save")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            if showSaved {
                Text("Changes saved!")
                    .foregroundColor(.green)
            }

            Spacer()
        }
        .onAppear {
            newUsername = username
            newEmail = email
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    private func saveChanges() {
        username = newUsername
        email = newEmail
        showSaved = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showSaved = false
        }
    }
}

#Preview {
    SettingsView()
} 
