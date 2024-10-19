import Foundation

class AuthService {
    private var settings: DebugSettings

    init(settings: DebugSettings) {
            self.settings = settings
    }

    // MARK: - Register User
    func registerUser(login: String, password: String, completion: @escaping (Result<AuthUser, AuthError>) -> Void) {
        guard let url = URL(string: "\(settings.baseURL)/user/register") else {
            completion(.failure(.invalidURL))
            return
        }

        let body: [String: String] = ["login": login, "password": password]
        let requestBody = try? JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBody

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed(error.localizedDescription)))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 201:
                    if let data = data, let user = try? JSONDecoder().decode(AuthUser.self, from: data) {
                        completion(.success(user))
                    } else {
                        completion(.failure(.invalidData))
                    }
                case 409:
                    completion(.failure(.userAlreadyExists))
                default:
                    completion(.failure(.unknownError))
                }
            }
        }.resume()
    }

    // MARK: - Login User
    func loginUser(login: String, password: String, completion: @escaping (Result<String, AuthError>) -> Void) {
        guard let url = URL(string: "\(settings.baseURL)/user/login") else {
            completion(.failure(.invalidURL))
            return
        }

        let body: [String: String] = ["login": login, "password": password]
        let requestBody = try? JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = requestBody

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.requestFailed(error.localizedDescription)))
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                switch httpResponse.statusCode {
                case 200:
                    completion(.success("Login successful"))
                case 401:
                    completion(.failure(.invalidCredentials))
                default:
                    completion(.failure(.unknownError))
                }
            }
        }.resume()
    }
}

// MARK: - User Model
struct AuthUser: Codable {
    let id: Int
    let login: String
    let password: String
}

// MARK: - Auth Error Enum
enum AuthError: Error {
    case invalidURL
    case requestFailed(String)
    case invalidData
    case userAlreadyExists
    case invalidCredentials
    case unknownError
}
