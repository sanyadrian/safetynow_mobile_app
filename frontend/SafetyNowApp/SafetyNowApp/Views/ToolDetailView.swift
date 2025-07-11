import SwiftUI

struct ToolDetailView: View {
    let tool: Tool
    @State private var showShareSheet = false
    @State private var shareContent: [Any] = []
    
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            ScrollView {
                VStack(alignment: .center, spacing: 48) {
                    // Title
                    Text("Tool Details")
                        .font(.system(size: 48, weight: .bold))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .center)
                    Text(tool.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 32)
                    if let description = tool.description, !description.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            let lines = description.components(separatedBy: .newlines)
                            ForEach(Array(lines.enumerated()), id: \.offset) { tuple in
                                let idx = tuple.offset
                                let line = tuple.element
                                let trimmed = line.trimmingCharacters(in: .whitespaces)
                                if trimmed.isEmpty {
                                    Spacer().frame(height: 10)
                                } else if trimmed == trimmed.uppercased() && trimmed.rangeOfCharacter(from: .letters) != nil {
                                    Spacer().frame(height: idx == 0 ? 0 : 16)
                                    Text(trimmed)
                                        .font(.body).bold()
                                        .foregroundColor(.black)
                                    Spacer().frame(height: 8)
                                } else {
                                    Text(trimmed)
                                        .font(.body)
                                        .foregroundColor(.black)
                                    Spacer().frame(height: 6)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color(.systemGray4).opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    Spacer(minLength: 24)
                    
                    // Share button for iPad
                    HStack(spacing: 16) {
                        Button(action: {
                            if let pdfURL = createPDF(for: tool.title, description: tool.description) {
                                if FileManager.default.fileExists(atPath: pdfURL.path),
                                   let fileSize = try? FileManager.default.attributesOfItem(atPath: pdfURL.path)[.size] as? UInt64,
                                   fileSize > 0 {
                                    shareContent = [pdfURL]
                                    showShareSheet = true
                                } else {
                                    print("PDF file does not exist or is empty")
                                }
                            } else {
                                print("Failed to create PDF")
                            }
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 80)
                }
                .padding(.vertical, 60)
            }
            .sheet(isPresented: $showShareSheet) {
                if let url = shareContent.first as? URL {
                    ShareSheet(activityItems: [url])
                }
            }
            .id((shareContent.first as? URL)?.absoluteString ?? UUID().uuidString)
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text(tool.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.top, 32)
                    if let description = tool.description, !description.isEmpty {
                        VStack(alignment: .leading, spacing: 0) {
                            let lines = description.components(separatedBy: .newlines)
                            ForEach(Array(lines.enumerated()), id: \.offset) { tuple in
                                let idx = tuple.offset
                                let line = tuple.element
                                let trimmed = line.trimmingCharacters(in: .whitespaces)
                                if trimmed.isEmpty {
                                    Spacer().frame(height: 10)
                                } else if trimmed == trimmed.uppercased() && trimmed.rangeOfCharacter(from: .letters) != nil {
                                    Spacer().frame(height: idx == 0 ? 0 : 16)
                                    Text(trimmed)
                                        .font(.body).bold()
                                        .foregroundColor(.black)
                                    Spacer().frame(height: 8)
                                } else {
                                    Text(trimmed)
                                        .font(.body)
                                        .foregroundColor(.black)
                                    Spacer().frame(height: 6)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color(.systemGray4).opacity(0.1), radius: 2, x: 0, y: 1)
                    }
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
                            if FileManager.default.fileExists(atPath: pdfURL.path),
                               let fileSize = try? FileManager.default.attributesOfItem(atPath: pdfURL.path)[.size] as? UInt64,
                               fileSize > 0 {
                                shareContent = [pdfURL]
                                showShareSheet = true
                            } else {
                                print("PDF file does not exist or is empty")
                            }
                        } else {
                            print("Failed to create PDF")
                        }
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .background(Color.white.ignoresSafeArea())
            .sheet(isPresented: $showShareSheet) {
                if let url = shareContent.first as? URL {
                    ShareSheet(activityItems: [url])
                }
            }
            .id((shareContent.first as? URL)?.absoluteString ?? UUID().uuidString)
        }
    }
} 