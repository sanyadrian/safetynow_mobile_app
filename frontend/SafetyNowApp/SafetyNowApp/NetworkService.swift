import Foundation

class NetworkService {
    static let shared = NetworkService()
    let baseURL = "https://safetynow-app.com"

    private init() {}

    func login(username: String, password: String, completion: @escaping (Result<TokenResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let cleanUsername = username.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let parameters = [
            "username": cleanUsername,
            "password": cleanPassword
        ]
        
        let bodyString = parameters
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Debug print
        print("Login attempt for username: \(cleanUsername)")
        print("Request URL: \(url)")
        print("Request body: \(bodyString)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Response status code: \(httpResponse.statusCode)")
            }

            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }

            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Error response: \(responseString)")
                }
                
                if let backendError = try? JSONDecoder().decode([String: String].self, from: data),
                   let detail = backendError["detail"] ?? backendError["message"] {
                    completion(.failure(NetworkError.backendMessage(detail)))
                } else {
                    completion(.failure(NetworkError.serverError))
                }
                return
            }

            do {
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                completion(.success(tokenResponse))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(NetworkError.decodingError))
            }
        }.resume()
    }

    func getTalks(token: String, language: String? = nil, completion: @escaping (Result<[TalkModel], Error>) -> Void) {
        var urlString = "\(baseURL)/talks/"
        if let language = language {
            urlString += "?language=\(language)"
        }
        guard let url = URL(string: urlString) else {
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
                let talks = try JSONDecoder().decode([TalkModel].self, from: data)
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

    func addToHistory(token: String, talkTitle: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/history/") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let language = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
        let body = ["talk_title": talkTitle, "language": language]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(NetworkError.encodingError))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.serverError))
                return
            }

            switch httpResponse.statusCode {
            case 200...299:
                completion(.success(()))
            default:
                completion(.failure(NetworkError.serverError))
            }
        }.resume()
    }

    func register(username: String, email: String, phone: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/auth/register") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        let body: [String: String] = [
            "username": username,
            "email": email,
            "phone": phone,
            "password": password
        ]

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            completion(.failure(NetworkError.encodingError))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.serverError))
                return
            }

            if !(200...299).contains(httpResponse.statusCode) {
                if let backendError = try? JSONDecoder().decode([String: String].self, from: data),
                   let detail = backendError["detail"] ?? backendError["message"] {
                    completion(.failure(NetworkError.backendMessage(detail)))
                } else {
                    completion(.failure(NetworkError.serverError))
                }
                return
            }

            completion(.success(()))
        }.resume()
    }

    func uploadProfileImage(image: Data, token: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/profile/upload-image") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"profile.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(image)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

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
                let response = try JSONDecoder().decode([String: String].self, from: data)
                if let profileImage = response["profile_image"] {
                    completion(.success(profileImage))
                } else {
                    completion(.failure(NetworkError.decodingError))
                }
            } catch {
                completion(.failure(NetworkError.decodingError))
            }
        }.resume()
    }

    func submitTicket(ticket: Ticket, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/ticket/") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "access_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            completion(.failure(NetworkError.serverError))
            return
        }

        do {
            let jsonData = try JSONEncoder().encode(ticket)
            request.httpBody = jsonData
        } catch {
            completion(.failure(NetworkError.encodingError))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.serverError))
                return
            }

            switch httpResponse.statusCode {
            case 200...299:
                completion(.success(()))
            case 401:
                completion(.failure(NetworkError.serverError))
            default:
                completion(.failure(NetworkError.serverError))
            }
        }.resume()
    }

    func deleteHistoryItem(token: String, historyId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/history/\(historyId)") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
                completion(.failure(NetworkError.serverError))
                return
            }
            completion(.success(()))
        }.resume()
    }

    func getTalkByTitle(token: String, title: String, completion: @escaping (Result<TalkModel, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/talks/") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            do {
                let talks = try JSONDecoder().decode([TalkModel].self, from: data)
                if let talk = talks.first(where: { $0.title == title }) {
                    completion(.success(talk))
                } else {
                    completion(.failure(NetworkError.noData))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    func requestPasswordReset(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/auth/forgot-password") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["email": email]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(NetworkError.encodingError))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.serverError))
                return
            }

            if !(200...299).contains(httpResponse.statusCode) {
                if let backendError = try? JSONDecoder().decode([String: String].self, from: data),
                   let detail = backendError["detail"] ?? backendError["message"] {
                    completion(.failure(NetworkError.backendMessage(detail)))
                } else {
                    completion(.failure(NetworkError.serverError))
                }
                return
            }

            completion(.success(()))
        }.resume()
    }

    func verifyResetCode(email: String, code: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/auth/verify-reset-code") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = [
            "email": email,
            "code": code
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(NetworkError.encodingError))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.serverError))
                return
            }

            if !(200...299).contains(httpResponse.statusCode) {
                if let backendError = try? JSONDecoder().decode([String: String].self, from: data),
                   let detail = backendError["detail"] ?? backendError["message"] {
                    completion(.failure(NetworkError.backendMessage(detail)))
                } else {
                    completion(.failure(NetworkError.serverError))
                }
                return
            }

            completion(.success(()))
        }.resume()
    }

    func resetPassword(email: String, code: String, newPassword: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/auth/reset-password") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = [
            "email": email,
            "code": code,
            "new_password": newPassword
        ]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(NetworkError.encodingError))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.serverError))
                return
            }

            if !(200...299).contains(httpResponse.statusCode) {
                if let backendError = try? JSONDecoder().decode([String: String].self, from: data),
                   let detail = backendError["detail"] ?? backendError["message"] {
                    completion(.failure(NetworkError.backendMessage(detail)))
                } else {
                    completion(.failure(NetworkError.serverError))
                }
                return
            }

            completion(.success(()))
        }.resume()
    }
}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

