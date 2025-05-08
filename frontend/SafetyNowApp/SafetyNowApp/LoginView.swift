import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var loginMessage = ""
    @AppStorage("access_token") var accessToken: String = ""
    @State private var isLoggedIn = false
    @AppStorage("username") var storedUsername: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Login").font(.largeTitle).bold()

                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Login") {
                    login()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                Text(loginMessage)
                    .foregroundColor(.red)

                NavigationLink(destination: DashboardView(), isActive: $isLoggedIn) {
                    EmptyView()
                }
            }
            .padding()
        }
    }

    func login() {
        NetworkService.shared.login(username: username, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    accessToken = response.access_token
                    storedUsername = response.user.username
                    isLoggedIn = true
                case .failure(let error):
                    loginMessage = "\(error.localizedDescription)"
                    isLoggedIn = false
                }
            }
        }
    }
}
