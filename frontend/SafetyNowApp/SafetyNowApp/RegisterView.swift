
import SwiftUI

struct RegisterView: View {
    @Binding var currentIndex: Int
    @State private var username = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var registerMessage = ""
    @State private var showLogin = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                // Title and Subtitle
                VStack(alignment: .leading, spacing: 10) {
                    Text("Create Your")
                        .font(.largeTitle)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Account")
                        .font(.largeTitle)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Text("Unlock compliant safety talks that reduce accidents & incidents rates, as well as workers comp premiums.")
                        .font(.callout)
                        .foregroundColor(.gray)
                }

                // Input Fields
                Group {
                    TextField("Username", text: $username)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                    TextField("Phone Number", text: $phone)
                        .keyboardType(.phonePad)
                    SecureField("Password", text: $password)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

                // Register Button
                Button(action: register) {
                    Text("Register")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // Message
                if !registerMessage.isEmpty {
                    Text(registerMessage)
                        .foregroundColor(.red)
                }

                Spacer()

                // Link to Login
                HStack {
                    Text("Already have an account?")
                    Button("Login") {
                        showLogin = true
                    }
                    .foregroundColor(.blue)
                    .bold()
                }
                .font(.footnote)

                NavigationLink(destination: LoginView(currentIndex: $currentIndex), isActive: $showLogin) { EmptyView() }
            }
            .padding()
        }
    }

    func register() {
        NetworkService.shared.register(username: username, email: email, phone: phone, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    registerMessage = "Registration successful!"
                    showLogin = true
                case .failure(let error):
                    registerMessage = "\(error.localizedDescription)"
                }
            }
        }
    }
}
