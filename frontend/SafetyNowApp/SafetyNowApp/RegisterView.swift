import SwiftUI

struct Country: Identifiable, Hashable {
    let id = UUID()
    let code: String
    let flag: String
    let dial: String
}

let countries = [
    Country(code: "US", flag: "🇺🇸", dial: "+1"),
    Country(code: "CA", flag: "🇨🇦", dial: "+1"),
    Country(code: "GB", flag: "🇬🇧", dial: "+44"),
    Country(code: "UA", flag: "🇺🇦", dial: "+380"),
    Country(code: "DE", flag: "🇩🇪", dial: "+49")
]

struct RegisterView: View {
    @Binding var currentIndex: Int
    @State private var username = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var registerMessage = ""
    @State private var showLogin = false
    @State private var selectedCountry = countries[0]

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
                        .autocapitalization(.none)
                        .textInputAutocapitalization(.never)
                    HStack {
                        Menu {
                            ForEach(countries) { country in
                                Button(action: { selectedCountry = country }) {
                                    Text("\(country.flag) \(country.dial)")
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedCountry.flag)
                                Text(selectedCountry.dial)
                                    .foregroundColor(.primary)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                        }
                        TextField("Phone Number", text: $phone)
                            .keyboardType(.phonePad)
                    }
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

    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    func register() {
        // Frontend validation
        if username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            password.isEmpty {
            registerMessage = "All fields are required."
            return
        }
        if !isValidEmail(email) {
            registerMessage = "Please enter a valid email address."
            return
        }
        if password.count < 8 {
            registerMessage = "Password must be at least 8 characters."
            return
        }
        let fullPhone = selectedCountry.dial + phone
        NetworkService.shared.register(username: username, email: email, phone: fullPhone, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    registerMessage = "Registration successful!"
                    showLogin = true
                case .failure(let error):
                    if let networkError = error as? NetworkError {
                        switch networkError {
                        case .backendMessage(let message):
                            registerMessage = message
                        default:
                            registerMessage = error.localizedDescription
                        }
                    } else {
                        registerMessage = error.localizedDescription
                    }
                }
            }
        }
    }
}
