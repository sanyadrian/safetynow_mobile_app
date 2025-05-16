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
                        Text("Talk to SafetyNow")
                            .font(.title)
                            .bold()
                        Text("Submit your safety concerns or questions")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top)
                    
                    VStack(spacing: 16) {
                        TextField("Your Name", text: $name)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .onAppear {
                                email = storedEmail
                            }
                        
                        TextField("Phone", text: $phone)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.phonePad)
                            .onAppear {
                                phone = storedPhone
                            }
                        
                        TextField("Topic", text: $topic)
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
                                        Text("Your message")
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
                            Text("Submit Ticket")
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
            .alert("Ticket Submission", isPresented: $showAlert) {
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
            alertMessage = "Please fill in all fields"
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
                    alertMessage = "Ticket submitted successfully! We'll contact you at \(email)"
                case .failure(let error):
                    alertMessage = "Failed to submit ticket: \(error.localizedDescription)"
                }
                showAlert = true
            }
        }
    }
} 
