import Foundation

struct User: Codable {
    let id: Int
    let username: String
    let email: String
    let phone: String
}

struct TokenResponse: Codable {
    let access_token: String
    let token_type: String
}

struct Talk: Codable, Identifiable {
    let id: Int
    let title: String
    let category: String
    let description: String?
}

struct HistoryItem: Codable {
    let id: Int
    let talk_title: String
    let accessed_at: String
}

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
}

