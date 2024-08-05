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


enum APIError: Error {
    case invalidResponse
    case clientError(message: String)
    case accessTokenRevoked
    case serverError
}

class URLSessionAPIClient<EndpointType: APIEndpoint>: APIClient {
    
    private let urlCache: URLCache
    
    init(urlCache: URLCache = .shared) {
        self.urlCache = urlCache
    }
    
    func request<T: Decodable>(_ endpoint: EndpointType) async throws -> T  {
        let url = endpoint.baseURL.appendingPathComponent(endpoint.path)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        if endpoint.method == .get {
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
      
        if endpoint.method == .post || endpoint.method == .put {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: endpoint.parameters)
            } catch {
                throw APIError.clientError(message: "Invalid Body Parameters")
            }
        }
        
        
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse else {
            throw APIError.serverError
        }
        
        switch response.statusCode {
        case 400 ..< 500:
            if response.statusCode == 401 {
                throw APIError.accessTokenRevoked
            }
            throw APIError.clientError(message: response.debugDescription)
        case 500 ..< 600:
            throw APIError.serverError
        default: break
        }
        
        let cachedResponse = CachedURLResponse(response: response, data: data)
        urlCache.storeCachedResponse(cachedResponse, for: URLRequest(url: url))
        
        
        let decodedData = try JSONDecoder().decode(T.self, from: data)
        
        return decodedData
    }
}
