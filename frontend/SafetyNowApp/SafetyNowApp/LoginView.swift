import SwiftUI

struct LoginView: View {
    @Binding var currentIndex: Int
    @State private var username = ""
    @State private var password = ""
    @State private var loginMessage = ""
    @AppStorage("profile_image") var profileImage: String = ""
    @AppStorage("access_token") var accessToken: String = ""
    @AppStorage("username") var storedUsername: String = ""
    @State private var isLoggedIn = false
    @State private var showRegister = false
    @State private var selectedTab: Tab = .home

    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Welcome To")
                        .font(.largeTitle).bold()

                    (Text("Safety Now").foregroundColor(.blue))
                        .font(.largeTitle).bold()

                    Text("Unlock Compliant\nFree Safety Talks")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.gray)
                }.frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal)

                TextField("Username", text: $username)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                HStack {
                    Spacer()
                    Button("Forgot Password?") {
                    }
                    .font(.footnote)
                    .foregroundColor(.blue)
                }

                Button(action: login) {
                    Text("Login")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                if !loginMessage.isEmpty {
                    Text(loginMessage)
                        .foregroundColor(.red)
                }

                Spacer()

                HStack {
                    Text("Don't have an account?")
                    Button("Register") {
                        showRegister = true
                    }
                    .foregroundColor(.blue)
                    .bold()
                }
                .font(.footnote)

                // Navigation links
                NavigationLink(destination: MainView(), isActive: $isLoggedIn) {
                    EmptyView()
                }
                NavigationLink(destination: RegisterView(currentIndex: $currentIndex), isActive: $showRegister) {
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
                    profileImage = response.user.profile_image ?? ""
                    UserDefaults.standard.set(response.user.email, forKey: "email")
                    UserDefaults.standard.set(response.user.phone, forKey: "phone")
                    isLoggedIn = true
                case .failure(let error):
                    loginMessage = "\(error.localizedDescription)"
                }
            }
        }
    }
}
