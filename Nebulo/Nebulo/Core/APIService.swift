//
//  APIService.swift
//  Nebulo
//
//  Created by apprenant152 on 27/04/2026.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, message: String)
    case decodingError

    var errorDescription: String? {
        switch self {
        case .invalidURL:           return "URL invalide"
        case .invalidResponse:      return "Réponse invalide"
        case .httpError(_, let msg): return msg
        case .decodingError:        return "Erreur de décodage"
        }
    }
}

final class APIService {
    static let shared = APIService()

    private let baseURL = "http://127.0.0.1:8080"

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    private init() {}

    func post<Response: Decodable, Body: Encodable>(
        endpoint: String,
        body: Body,
        token: String? = nil
    ) async throws -> Response {
        let request = try buildRequest(endpoint: endpoint, method: "POST", body: body, token: token)
        return try await perform(request)
    }

    func put<Response: Decodable, Body: Encodable>(
        endpoint: String,
        body: Body,
        token: String
    ) async throws -> Response {
        let request = try buildRequest(endpoint: endpoint, method: "PUT", body: body, token: token)
        return try await perform(request)
    }

    func get<Response: Decodable>(endpoint: String, token: String) async throws -> Response {
        let request = try buildRequest(endpoint: endpoint, method: "GET", body: Optional<String>.none, token: token)
        return try await perform(request)
    }

    /// Certaines lectures répondent `204 No Content` quand il n'y a rien à
    /// lire — le challenge courant, une fois le pool épuisé. Le corps est alors
    /// vide et le décodeur n'a rien à se mettre sous la dent : d'où le nil.
    func getOptional<Response: Decodable>(endpoint: String, token: String) async throws -> Response? {
        let request = try buildRequest(endpoint: endpoint, method: "GET", body: Optional<String>.none, token: token)
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard http.statusCode != 204 else { return nil }

        guard (200...299).contains(http.statusCode) else {
            let message = (try? decoder.decode(APIErrorResponse.self, from: data))?.reason
                ?? "Erreur \(http.statusCode)"
            throw APIError.httpError(statusCode: http.statusCode, message: message)
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }

    /// Certaines suppressions répondent avec la ressource remise à jour —
    /// retirer un vote renvoie le post recompté — d'où le type de retour.
    func delete<Response: Decodable>(endpoint: String, token: String) async throws -> Response {
        let request = try buildRequest(endpoint: endpoint, method: "DELETE", body: Optional<String>.none, token: token)
        return try await perform(request)
    }

    private func buildRequest<Body: Encodable>(
        endpoint: String,
        method: String,
        body: Body?,
        token: String?
    ) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        if let body {
            request.httpBody = try encoder.encode(body)
        }
        return request
    }

    private func perform<Response: Decodable>(_ request: URLRequest) async throws -> Response {
        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            let message = (try? decoder.decode(APIErrorResponse.self, from: data))?.reason
                ?? "Erreur \(http.statusCode)"
            throw APIError.httpError(statusCode: http.statusCode, message: message)
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decodingError
        }
    }
}

private struct APIErrorResponse: Decodable {
    let reason: String
}
