import SwiftUI

struct UpgradePlanView: View {
    @AppStorage("email") var email: String = ""
    @AppStorage("phone") var phone: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var company: String = ""
    @State private var showForm = false
    @State private var selectedPlan: String = ""
    @State private var isLoading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 24)
            Image("devices_mockup")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 220, height: 120)
                .cornerRadius(12)
                .padding(.top, 16)

            Text("Upgrade Your Plan")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 8)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("SafetyNow ILT")
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                    Text("$ 50")
                        .font(.title3)
                        .fontWeight(.bold)
                }
                Text("Unlock all Training")
                    .fontWeight(.bold)
                Text("Lower workers comp premiums by 40%")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Up to 3 sharing devices")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Button(action: {
                    selectedPlan = "SafetyNow ILT"
                    showForm = true
                }) {
                    Text("Select Plan")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(20)
            .shadow(color: Color(.systemGray4).opacity(0.2), radius: 8, x: 0, y: 2)
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("SafetyNow")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    Text("$5/")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text("learner")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.top, 6)
                }
                Text("Unlock all Training")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Access 6,000+ elearning courses")
                    .font(.subheadline)
                    .foregroundColor(.white)
                Text("Award-winning LMS")
                    .font(.subheadline)
                    .foregroundColor(.white)
                Text("Train online and offline")
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Button(action: {
                    selectedPlan = "SafetyNow"
                    showForm = true
                }) {
                    Text("Select Plan")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                }
            }
            .padding()
            .background(Color.blue)
            .cornerRadius(20)
            .padding(.horizontal)

            Spacer()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .sheet(isPresented: $showForm) {
            NavigationStack {
                Form {
                    Section(header: Text("Personal Information")) {
                        TextField("First Name", text: $firstName)
                        TextField("Last Name", text: $lastName)
                        TextField("Company", text: $company)
                        TextField("Email", text: $email)
                            .disabled(true)
                        TextField("Phone", text: $phone)
                            .disabled(true)
                    }
                    
                    Section {
                        Button(action: submitLead) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Submit")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(isLoading)
                    }
                }
                .navigationTitle("Upgrade to \(selectedPlan)")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showForm = false
                        }
                    }
                }
            }
        }
        .alert("Upgrade Plan", isPresented: $showAlert) {
            Button("OK") {
                if alertMessage.contains("success") {
                    showForm = false
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func submitLead() {
        isLoading = true
        
        // Create lead data
        let leadData: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "company": company,
            "email": email,
            "phone": phone,
            "plan": selectedPlan
        ]
        
        // Convert to JSON
        guard let jsonData = try? JSONSerialization.data(withJSONObject: leadData) else {
            alertMessage = "Error preparing data"
            showAlert = true
            isLoading = false
            return
        }
        
        // Create URL request
        guard let url = URL(string: "http://localhost:8000/api/create-lead") else {
            alertMessage = "Invalid URL"
            showAlert = true
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Send request
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    alertMessage = "Error: \(error.localizedDescription)"
                    showAlert = true
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    alertMessage = "Invalid response"
                    showAlert = true
                    return
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    alertMessage = "Success! We'll contact you shortly."
                } else {
                    if let data = data,
                       let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let detail = errorResponse["detail"] as? String {
                        alertMessage = "Error: \(detail)"
                    } else {
                        alertMessage = "Error: Please try again later"
                    }
                }
                showAlert = true
            }
        }.resume()
    }
}

#Preview {
    UpgradePlanView()
} 
