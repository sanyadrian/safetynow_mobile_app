import SwiftUI

struct ToolDetailView: View {
    let tool: Tool
    @State private var showShareSheet = false
    @State private var shareContent: [Any] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(tool.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 32)
                if let description = tool.description, !description.isEmpty {
                    Text(description)
                        .font(.body)
                }
                // if !tool.category.isEmpty {
                //     Text("Category: \(tool.category)")
                //         .font(.subheadline)
                //         .foregroundColor(.secondary)
                // }
                // if let hazard = tool.hazard, !hazard.isEmpty {
                //     Text("Hazard: \(hazard)")
                //         .font(.subheadline)
                //         .foregroundColor(.secondary)
                // }
                // if let industry = tool.industry, !industry.isEmpty {
                //     Text("Industry: \(industry)")
                //         .font(.subheadline)
                //         .foregroundColor(.secondary)
                // }
                // if !tool.language.isEmpty {
                //     Text("Language: \(tool.language)")
                //         .font(.subheadline)
                //         .foregroundColor(.secondary)
                // }
                // if !tool.related_title.isEmpty {
                //     Text("Related: \(tool.related_title)")
                //         .font(.subheadline)
                //         .foregroundColor(.secondary)
                // }
                Spacer(minLength: 24)
            }
            .padding()
        }
        .navigationTitle("Tool Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if let pdfURL = createPDF(for: tool.title, description: tool.description) {
                        shareContent = [pdfURL]
                        showShareSheet = true
                    }
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: shareContent)
        }
    }
} 