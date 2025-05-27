import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var resetCode = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var message = ""
    @State private var isCodeSent = false
    @State private var isCodeVerified = false
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 25) {
                // Title
                VStack(alignment: .leading, spacing: 10) {
                    Text("Reset Your")
                        .font(.largeTitle)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Password")
                        .font(.largeTitle)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                if !isCodeSent {
                    // Step 1: Enter Email
                    VStack(spacing: 15) {
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
                        Button(action: requestResetCode) {
                            Text("Send Reset Code")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                } else if !isCodeVerified {
                    // Step 2: Enter Reset Code
                    VStack(spacing: 15) {
                        Text("Enter the 6-digit code sent to your email")
                            .foregroundColor(.gray)
                        
                        TextField("Reset Code", text: $resetCode)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        
                        Button(action: verifyCode) {
                            Text("Verify Code")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                } else {
                    // Step 3: Enter New Password
                    VStack(spacing: 15) {
                        HStack {
                            if showPassword {
                                TextField("New Password", text: $newPassword)
                            } else {
                                SecureField("New Password", text: $newPassword)
                            }
                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        
                        HStack {
                            if showConfirmPassword {
                                TextField("Confirm Password", text: $confirmPassword)
                            } else {
                                SecureField("Confirm Password", text: $confirmPassword)
                            }
                            Button(action: { showConfirmPassword.toggle() }) {
                                Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        
                        Button(action: resetPassword) {
                            Text("Reset Password")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                
                if !message.isEmpty {
                    Text(message)
                        .foregroundColor(message.contains("successful") ? .green : .red)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func requestResetCode() {
        guard !email.isEmpty else {
            message = "Please enter your email address"
            return
        }
        
        NetworkService.shared.requestPasswordReset(email: email) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    message = "Reset code has been sent to your email"
                    isCodeSent = true
                case .failure(let error):
                    if let networkError = error as? NetworkError {
                        switch networkError {
                        case .backendMessage(let message):
                            self.message = message
                        default:
                            self.message = error.localizedDescription
                        }
                    } else {
                        self.message = error.localizedDescription
                    }
                }
            }
        }
    }
    
    private func verifyCode() {
        guard !resetCode.isEmpty else {
            message = "Please enter the reset code"
            return
        }
        
        NetworkService.shared.verifyResetCode(email: email, code: resetCode) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    message = "Code verified successfully"
                    isCodeVerified = true
                case .failure(let error):
                    if let networkError = error as? NetworkError {
                        switch networkError {
                        case .backendMessage(let message):
                            self.message = message
                        default:
                            self.message = error.localizedDescription
                        }
                    } else {
                        self.message = error.localizedDescription
                    }
                }
            }
        }
    }
    
    private func resetPassword() {
        guard !newPassword.isEmpty else {
            message = "Please enter a new password"
            return
        }
        
        guard newPassword == confirmPassword else {
            message = "Passwords do not match"
            return
        }
        
        guard newPassword.count >= 8 else {
            message = "Password must be at least 8 characters"
            return
        }
        
        NetworkService.shared.resetPassword(email: email, code: resetCode, newPassword: newPassword) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    message = "Password reset successful"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        dismiss()
                    }
                case .failure(let error):
                    if let networkError = error as? NetworkError {
                        switch networkError {
                        case .backendMessage(let message):
                            self.message = message
                        default:
                            self.message = error.localizedDescription
                        }
                    } else {
                        self.message = error.localizedDescription
                    }
                }
            }
        }
    }
} 