import SwiftUI

struct TicketSubmissionView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("email") var storedEmail: String = ""
    @AppStorage("phone") var storedPhone: String = ""
    @State private var name = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var topic = ""
    @State private var message = ""
    @State private var isSubmitting = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizationManager.shared.localizedString(for: "ticket.title"))
                            .font(.title)
                            .bold()
                        Text(LocalizationManager.shared.localizedString(for: "ticket.subtitle"))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                    
                    VStack(spacing: 16) {
                        TextField(LocalizationManager.shared.localizedString(for: "ticket.name_placeholder"), text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField(LocalizationManager.shared.localizedString(for: "ticket.email_placeholder"), text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .onAppear {
                                email = storedEmail
                            }
                        
                        TextField(LocalizationManager.shared.localizedString(for: "ticket.phone_placeholder"), text: $phone)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.phonePad)
                            .onAppear {
                                phone = storedPhone
                            }
                        
                        TextField(LocalizationManager.shared.localizedString(for: "ticket.topic_placeholder"), text: $topic)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextEditor(text: $message)
                            .frame(height: 150)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .overlay(
                                Group {
                                    if message.isEmpty {
                                        Text(LocalizationManager.shared.localizedString(for: "ticket.message_placeholder"))
                                            .foregroundColor(.gray)
                                            .padding(.leading, 4)
                                            .padding(.top, 8)
                                    }
                                },
                                alignment: .topLeading
                            )
                    }
                    
                    Button(action: submitTicket) {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(LocalizationManager.shared.localizedString(for: "ticket.submit_button"))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(isSubmitting)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.gray)
                    }
                }
            }
            .alert(LocalizationManager.shared.localizedString(for: "ticket.alert_title"), isPresented: $showAlert) {
                Button("OK") {
                    if alertMessage.contains("success") {
                        dismiss()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func submitTicket() {
        guard !name.isEmpty, !email.isEmpty, !phone.isEmpty, !topic.isEmpty, !message.isEmpty else {
            alertMessage = LocalizationManager.shared.localizedString(for: "ticket.fill_all_fields")
            showAlert = true
            return
        }
        
        isSubmitting = true
        
        let ticket = Ticket(name: name, email: email, phone: phone, topic: topic, message: message)
        
        NetworkService.shared.submitTicket(ticket: ticket) { result in
            DispatchQueue.main.async {
                isSubmitting = false
                switch result {
                case .success:
                    alertMessage = String(format: LocalizationManager.shared.localizedString(for: "ticket.success"), email)
                case .failure(let error):
                    alertMessage = LocalizationManager.shared.localizedString(for: "ticket.failure") + ": " + error.localizedDescription
                }
                showAlert = true
            }
        }
    }
} 
