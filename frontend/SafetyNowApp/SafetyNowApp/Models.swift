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

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
}

