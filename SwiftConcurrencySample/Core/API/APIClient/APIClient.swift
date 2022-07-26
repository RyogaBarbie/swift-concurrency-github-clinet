//
//  APIClient.swift
//  SwiftConcurrencySample
//
//  Created by yamamura ryoga on 2022/07/09.
//

import Foundation

enum APIError: Error, Sendable {
    case badUrl
    case badRequest
    case unauthorized
    case notFound
    case methodNotAllowed
    case internalServerError
    case responseError
    case unknown(Int)

    public init(rawValue: Int){
        switch rawValue {
        case 400:
            self = .badRequest
        case 401:
            self = .unauthorized
        case 404:
            self = .notFound
        case 405:
            self = .methodNotAllowed
        case 500:
            self = .internalServerError
        default:
            self = .unknown(rawValue)
        }
    }
}

enum APIMethod: String {
    case get
    case post
    case put
    case delete
}

enum APIConst {
    static let baseUrl: String = "https://api.github.com"
}

protocol APIClientProtocol {
    func send<T: Request>(_ request: T) async throws -> T.Response
}

class APIClient: APIClientProtocol {
    private let urlSession: URLSession
    private let envClient: ENVClientProtocol

    init(
        urlSession: URLSession,
        envClient: ENVClientProtocol
    ) {
        self.urlSession = urlSession
        self.envClient = envClient
    }
    
    func send<T: Request>(_ request: T) async throws -> T.Response {
        guard var urlComponents = URLComponents(string: APIConst.baseUrl) else { throw APIError.badUrl }
        urlComponents.path = request.path
        urlComponents.queryItems = request.query.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let url = urlComponents.url else { throw APIError.badUrl }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body?.data(using: .utf8)
        urlRequest.allHTTPHeaderFields = [
            "Authorization": "token \(envClient.githubAccessToken)",
            "Accept": "application/vnd.github+json"
        ]

        let (data, response) = try await urlSession.data(for: urlRequest)

        // CheckStarの時に成功時の結果が204 or 404で返ってくるので
        // StatusCodeのvalidateの前にチェックする
        if let _ = request as? CheckStarRequest, T.Response.self == Bool.self {
            do {
                return try convertToBool(response: response) as! T.Response
            } catch {
                throw error
            }
        }

        do {
            try validate(response: response)
        } catch {
            if let apiError = error as? APIError {
                throw apiError
            }
            throw error
        }
        
        guard data.count > 0 else {
            if let response = EmptyResponse() as? T.Response {
                return response
            } else {
                throw APIError.responseError
            }
        }

        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        jsonDecoder.dateDecodingStrategy = .iso8601
        
        return try jsonDecoder.decode(T.Response.self, from: data)
    }
    
    private func validate(response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else { return }
        if !(200..<300).contains(httpResponse.statusCode) {
            throw APIError(rawValue: httpResponse.statusCode)
        }
    }
    
    private func convertToBool(response: URLResponse) throws -> Bool {
        guard let httpResponse = response as? HTTPURLResponse else { return false }
        if httpResponse.statusCode == 204 {
            return true
        } else if httpResponse.statusCode == 404 {
            return false
        } else {
            throw APIError.responseError
        }
    }
}
