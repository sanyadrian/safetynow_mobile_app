import SwiftUI

struct LoginView: View {
    @Binding var currentIndex: Int
    @State private var username = ""
    @State private var password = ""
    @State private var loginMessage = ""
    @AppStorage("profile_image") var profileImage: String = ""
    @AppStorage("access_token") var accessToken: String = ""
    @AppStorage("username") var storedUsername: String = ""
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @State private var showRegister = false
    @State private var showForgotPassword = false
    @State private var selectedTab: Tab = .home
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        NavigationStack {
            Group {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    ScrollView {
                        VStack(alignment: .center, spacing: 48) {
                            // Title and Subtitle
                            VStack(alignment: .center, spacing: 18) {
                                Text("Welcome to Safety Now")
                                    .font(.system(size: 48, weight: .bold))
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                Text("Unlock Compliant\nFree Safety Talks")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.horizontal, 80)
                            TextField("Username", text: $username)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(14)
                                .font(.title2)
                            SecureField("Password", text: $password)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(14)
                                .font(.title2)
                            HStack {
                                Spacer()
                                Button("Forgot Password?") {
                                    showForgotPassword = true
                                }
                                .font(.title3)
                                .foregroundColor(.blue)
                            }
                            .padding(.horizontal, 80)
                            Button(action: login) {
                                Text("Login")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(14)
                                    .font(.title2)
                            }
                            .padding(.horizontal, 80)
                            if !loginMessage.isEmpty {
                                Text(loginMessage)
                                    .foregroundColor(.red)
                                    .font(.title3)
                                    .padding(.horizontal, 80)
                            }
                            HStack {
                                Text("Don't have an account?")
                                    .font(.title3)
                                Button("Register") {
                                    showRegister = true
                                }
                                .foregroundColor(.blue)
                                .bold()
                                .font(.title3)
                            }
                            .padding(.horizontal, 80)
                            NavigationLink(destination: RegisterView(currentIndex: $currentIndex), isActive: $showRegister) { EmptyView() }
                            NavigationLink(destination: ForgotPasswordView(), isActive: $showForgotPassword) { EmptyView() }
                        }
                        .padding(.vertical, 60)
                    }
                } else {
                    // iPhone layout (original)
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
                                showForgotPassword = true
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
                        NavigationLink(destination: RegisterView(currentIndex: $currentIndex), isActive: $showRegister) {
                            EmptyView()
                        }
                        NavigationLink(destination: ForgotPasswordView(), isActive: $showForgotPassword) {
                            EmptyView()
                        }
                    }
                    .padding()
                }
            }
            // Navigation links for iPad (outside the Group)
            NavigationLink(destination: RegisterView(currentIndex: $currentIndex), isActive: $showRegister) {
                EmptyView()
            }
            NavigationLink(destination: ForgotPasswordView(), isActive: $showForgotPassword) {
                EmptyView()
            }
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
                    UserDefaults.standard.set(response.user.phone ?? "", forKey: "phone")
                    isLoggedIn = true
                case .failure(let error):
                    if let networkError = error as? NetworkError {
                        switch networkError {
                        case .backendMessage(let message):
                            loginMessage = message
                        default:
                            loginMessage = error.localizedDescription
                        }
                    } else {
                        loginMessage = error.localizedDescription
                    }
                }
            }
        }
    }
}
