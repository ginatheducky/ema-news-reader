//
//  EMAClient.swift
//  ema-news-reader
//
//  Created by christina on 09.11.26.
//

import Foundation

enum EMAClientError: Error, Equatable {
    case nonHTTPResponse
    case unsuccessfulStatus(Int)
}

struct EMAClient {
    private let request: (URL) async throws -> (Data, URLResponse)
    
    init(
        request: @escaping (URL) async throws -> (Data, URLResponse) = { url in
            try await URLSession.shared.data(from: url)
        }
    ) {
        self.request = request
    }
    
    func fetchData(from url: URL) async throws -> Data {
        let (data, response) = try await request(url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw EMAClientError.nonHTTPResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw EMAClientError.unsuccessfulStatus(
                httpResponse.statusCode
            )
        }
        
        return data
    }
}

