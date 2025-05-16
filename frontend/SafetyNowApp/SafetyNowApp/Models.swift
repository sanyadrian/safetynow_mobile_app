import Foundation


struct TokenResponse: Decodable {
    let access_token: String
    let token_type: String
    let user: User
}

struct User: Codable {
    let id: Int
    let username: String
    let email: String
    let phone: String
    let profile_image: String?
}

struct Talk: Codable, Identifiable {
    let id: Int
    let title: String
    let category: String
    let description: String?
}

struct HistoryItem: Codable, Identifiable {
    let id: Int
    let talk_title: String
    let accessed_at: String
}

struct TalkCategory: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

struct Ticket: Codable {
    let name: String
    let email: String
    let phone: String
    let topic: String
    let message: String
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case encodingError
    case serverError
}
