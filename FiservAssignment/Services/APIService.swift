//
//  APIService.swift
//  FiservAssignment
//
//  Created by Ailson Cordeiro Filho on 14/04/26.
//
import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    case limitExceeded
    case serverNotFound
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Error processing data"
        case .networkError(let error):
            return "\(error.localizedDescription)"
        case .limitExceeded:
            return "Daily request limit reached"
        case .serverNotFound:
            return "Server not found. Check your connection."
        case .unauthorized:
            return "Authentication error"
        }
    }
}

class APIService {
    static let shared = APIService()
    private let baseURL = "http://ktor-env.eba-asssfhm8.eu-west-1.elasticbeanstalk.com"
    private let username = "Advantage"
    private let password = "mobileAssignment"
    var urlSession: URLSession = URLSession.shared

    
    init() {}
    
    private func createRequest(endpoint: String, method: String = "GET") -> URLRequest? {
        guard let url = URL(string: baseURL + endpoint) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 30
        
        let loginString = "\(username):\(password)"
        guard let loginData = loginString.data(using: .utf8) else { return nil }
        let base64LoginString = loginData.base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
    func fetch<T: Decodable>(endpoint: String) async throws -> T {
        guard let request = createRequest(endpoint: endpoint) else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkError(NSError(domain: "", code: -1))
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                break
            case 401:
                throw APIError.unauthorized
            case 429:
                throw APIError.limitExceeded
            case 404:
                throw APIError.serverNotFound
            default:
                throw APIError.networkError(
                    NSError(domain: "", code: httpResponse.statusCode,
                           userInfo: [NSLocalizedDescriptionKey: "HTTP Error \(httpResponse.statusCode)"])
                )
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 JSON received from \(endpoint):")
                print(jsonString) 
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            return try decoder.decode(T.self, from: data)
        } catch let error as APIError {
            throw error
        } catch let decodingError as DecodingError {
            print("Decoding error: \(decodingError)")
            throw APIError.decodingError
        } catch {
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain && nsError.code == -1003 {
                throw APIError.serverNotFound
            }
            throw APIError.networkError(error)
        }
    }
    
    func fetchTransactions(
        accountId: String,
        nextPage: Int = 1,
        fromDate: String? = nil,
        toDate: String? = nil
    ) async throws -> [Transaction] {
        guard var request = createRequest(
            endpoint: "/account/transactions/\(accountId)",
            method: "POST"
        ) else {
            throw APIError.invalidURL
        }
        
        var body: [String: Any] = ["next_page": nextPage]
        
        if let fromDate = fromDate {
            body["from_date"] = fromDate
        }
        if let toDate = toDate {
            body["to_date"] = toDate
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.networkError(NSError(domain: "", code: -1))
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                break
            case 401:
                throw APIError.unauthorized
            case 404:
                throw APIError.serverNotFound
            default:
                throw APIError.networkError(
                    NSError(domain: "", code: httpResponse.statusCode)
                )
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📦 Received JSON from \(request.url?.relativeString ?? "N/A"):")
                print(jsonString)
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let responseData = try decoder.decode(TransactionsResponse.self, from: data)
            return responseData.transactions ?? []
        } catch let error as APIError {
            throw error
        } catch {
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain && nsError.code == -1003 {
                throw APIError.serverNotFound
            }
            throw APIError.networkError(error)
        }
    }
}
