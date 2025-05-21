import SwiftUI

struct UpgradePlanView: View {
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
                    .font(.headline)
                    .fontWeight(.bold)
                Text("Lower workers comp premiums by 40%")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("Up to 3 sharing devices")
                    .font(.subheadline)
                    .foregroundColor(.gray)
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
            }
            .padding()
            .background(Color.blue)
            .cornerRadius(20)
            .padding(.horizontal)

            Spacer()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

#Preview {
    UpgradePlanView()
} 
