//
//  APIClient.swift
//  NimbleSurvey
//
//  Created by Kazu on 3/8/24.
//

import Foundation

protocol APIClient {
    associatedtype EndpointType: APIEndpoint
    func request<T: Decodable>(_ endpoint: EndpointType) async throws -> T
}


enum APIError: Error, Equatable {
    case noInternetConnection
    case invalidResponse
    case clientError(message: String)
    case accessTokenRevoked
    case serverError
}

protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol { }

class URLSessionAPIClient<EndpointType: APIEndpoint>: APIClient {
    private let urlSession: URLSessionProtocol
    private let urlCache: URLCache
    
    init(urlCache: URLCache = .shared, urlSession: URLSessionProtocol = URLSession.shared) {
        self.urlCache = urlCache
        self.urlSession = urlSession
    }
    
    func request<T: Decodable>(_ endpoint: EndpointType) async throws -> T  {
        for attempt in 0..<2 {
            do {
                let request = try createRequest(for: endpoint)
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let response = response as? HTTPURLResponse else {
                    throw APIError.serverError
                }
                
                switch response.statusCode {
                case 400 ..< 500:
                    if response.statusCode == 401 {
                        if attempt == 0 {
                            try await refreshToken()
                            continue
                        } else {
                            throw APIError.accessTokenRevoked
                        }
                    }
                    if response.statusCode == 404 {
                        throw APIError.clientError(message: "Invalid URL")
                    }
                    throw APIError.clientError(message: response.debugDescription)
                case 500 ..< 600:
                    throw APIError.serverError
                default: break
                }
                
                let cachedResponse = CachedURLResponse(response: response, data: data)
                
                urlCache.storeCachedResponse(cachedResponse, for: request)
                
                
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                
                return decodedData
            } catch {
                if attempt == 1 { // If the second attempt fails, throw the error
                    throw error
                }
            }
        }
        throw APIError.serverError
    }
    
    private func createRequest(for endpoint: APIEndpoint) throws -> URLRequest {
        let url = endpoint.baseURL.appendingPathComponent(endpoint.path)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        // missing the case dont have any params
        if endpoint.method == .get && !(endpoint.parameters.isEmpty) {
            components?.queryItems = endpoint.parameters.map({ param in
                URLQueryItem(name: param.key, value: "\(param.value)")
            })
        }
        
        
        guard let newUrl = components?.url else {
            throw APIError.clientError(message: "Invalid URL")
        }
        
        var request = URLRequest(url: newUrl)
        request.httpMethod = endpoint.method.rawValue
        
        endpoint.headers?.forEach { request.addValue($0.value, forHTTPHeaderField: $0.key) }
        request.setValue(
            "Bearer \(KeychainManager.sharedInstance.get(Constant.KeychainKey.accessToken) ?? "")",
            forHTTPHeaderField: "Authorization"
        )
        
        if endpoint.method == .post || endpoint.method == .put {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: endpoint.parameters)
            } catch {
                throw APIError.clientError(message: "Invalid Body Parameters")
            }
        }
        
        return request
    }
    
    private func refreshToken() async throws {
        let request = try createRequest(for: UserEndpoint.refeshToken)

        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.serverError
        }
        
        switch httpResponse.statusCode {
        case 400 ..< 500:
            if httpResponse.statusCode == 401 {
                throw APIError.accessTokenRevoked
            }
            throw APIError.clientError(message: response.debugDescription)
        case 500 ..< 600:
            throw APIError.serverError
        default: break
        }
        
        let signInResponse = try JSONDecoder().decode(SignInResponse.self, from: data)
        KeychainManager.sharedInstance.set(signInResponse.data.attributes.accessToken, forKey: Constant.KeychainKey.accessToken)
    }
}
