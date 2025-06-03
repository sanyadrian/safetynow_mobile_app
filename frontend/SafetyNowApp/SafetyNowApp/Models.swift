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

struct Tool: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let category: String
    let description: String?
    let hazard: String?
    let industry: String?
    let language: String
    let related_title: String
    var likeCount: Int?
    var userLiked: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, title, category, description, hazard, industry, language, related_title
        case likeCount = "like_count"
        case userLiked = "user_liked"
    }
    
    // Implement Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Tool, rhs: Tool) -> Bool {
        lhs.id == rhs.id
    }
}

struct HistoryItem: Codable, Identifiable {
    let id: Int
    let talk_title: String
    let accessed_at: String
    let language: String
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
    case backendMessage(String)
}
