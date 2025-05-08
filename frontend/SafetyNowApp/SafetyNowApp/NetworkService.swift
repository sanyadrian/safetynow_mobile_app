import Foundation


class NetworkService {
    static let shared = NetworkService()
    private let baseURL = "http://192.168.4.25:8000"

    private init() {}

    func login(username: String, password: String, completion: @escaping (Result<TokenResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = "username=\(username)&password=\(password)"
        request.httpBody = body.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            do {
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                completion(.success(tokenResponse))
            } catch {
                completion(.failure(NetworkError.decodingError))
            }
        }.resume()
    }

    func getTalks(token: String, completion: @escaping (Result<[Talk], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/talks/") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            do {
                let talks = try JSONDecoder().decode([Talk].self, from: data)
                completion(.success(talks))
            } catch {
                completion(.failure(NetworkError.decodingError))
            }
        }.resume()
    }
    
    func getHistory(token: String, completion: @escaping (Result<[HistoryItem], Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/history/") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            do {
                let history = try JSONDecoder().decode([HistoryItem].self, from: data)
                completion(.success(history))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

}
