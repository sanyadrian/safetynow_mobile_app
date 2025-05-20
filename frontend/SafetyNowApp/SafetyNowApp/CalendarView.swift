import SwiftUI

struct CalendarView: View {
    var body: some View {
        VStack(spacing: 32) {
            Spacer().frame(height: 24)
            Text("Calendar")
                .font(.title)
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 8)

            HStack(spacing: 24) {
                monthCard(month: "January")
                monthCard(month: "February")
            }
            .padding(.horizontal)

            Spacer()
        }
        .background(Color.white.ignoresSafeArea())
    }

    private func monthCard(month: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "pencil")
                    .foregroundColor(.black)
                Spacer()
            }
            Text(month)
                .font(.headline)
                .foregroundColor(Color.blue)
                .fontWeight(.bold)
            Text("Search for a safety talk by workplace hazard.")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(width: 150, height: 150)
        .background(Color.white)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

#Preview {
    CalendarView()
} 