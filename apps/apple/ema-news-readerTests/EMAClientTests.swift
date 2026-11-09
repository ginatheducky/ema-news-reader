//
//  EMAClientTests.swift
//  ema-news-reader
//
//  Created by christina on 09.11.26.
//

import Foundation
import Testing
@testable import ema_news_reader

struct EMAClientTests {
    @MainActor
    @Test func rejectsHTTP404() async throws {
        let url = try #require(URL(string: "https://example.com/news"))
        
        let response = try #require(HTTPURLResponse(
            url: url,
            statusCode: 404,
            httpVersion: nil,
            headerFields: nil
        ))
        
        let client = EMAClient(request: { _ in
            (Data(), response)
        })
        
        await #expect(throws: EMAClientError.unsuccessfulStatus(404)) {
            try await client.fetchData(from: url)
        }
    }
    
    @MainActor
    @Test func returnsResponseDataForHTTP200() async throws {
        let url = try #require(URL(string: "https://example.com/news"))
        let expectedData = Data("hello".utf8)
        
        let response = try #require(HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        ))
        
        let client = EMAClient(request: { requestedURL in
            #expect(requestedURL == url)
            return (expectedData, response)
        })
        
        let actualData = try await client.fetchData(from: url)
        
        #expect(actualData == expectedData)
    }
    
    @MainActor
    @Test func rejectsNonHTTPResponse() async throws {
        let url = try #require(URL(string: "https://example.com/news"))
        
        let response = URLResponse(url: url, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
        
        let client = EMAClient(request: { _ in
            (Data(), response)
        })
        
        await #expect(throws: EMAClientError.nonHTTPResponse) {
            try await client.fetchData(from: url)
        }
    }
    
    @MainActor
    @Test func propagatesRequestCancellation() async throws {
        let url = try #require(URL(string: "https://example.com/news"))
        
        let client = EMAClient(request: { _ in
            throw CancellationError()
        })
        
        await #expect(throws: CancellationError.self) {
            try await client.fetchData(from: url)
        }
    }
    
    @MainActor
    @Test func propagatesNetworkError() async throws {
        let url = try #require(URL(string: "https://example.com/news"))
        
        let client = EMAClient(request: { _ in
            throw URLError(.notConnectedToInternet)
        })
        
        await #expect(throws: URLError.self) {
            try await client.fetchData(from: url)
        }
    }
}
