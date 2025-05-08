import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var loginMessage = ""
    @AppStorage("access_token") var accessToken: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Login").font(.largeTitle).bold()

            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Login") {
                login()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Text(loginMessage)
                .foregroundColor(.red)
        }
        .padding()
    }

    func login() {
        NetworkService.shared.login(username: username, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    accessToken = token
                    loginMessage = "✅ Logged in!"
                case .failure(let error):
                    loginMessage = "❌ \(error.localizedDescription)"
                }
            }
        }
    }
}
