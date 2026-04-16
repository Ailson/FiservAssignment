//
//  APIServiceTests.swift
//  FiservAssignmentTests
//
//  Created by Ailson Cordeiro Filho on 15/04/26.
//

import XCTest
@testable import FiservAssignment

// MARK: - Mock URLProtocol
class MockURLProtocol: URLProtocol {
    static var mockData: Data?
    static var mockResponse: HTTPURLResponse?
    static var mockError: Error?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let error = MockURLProtocol.mockError {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        
        if let response = MockURLProtocol.mockResponse {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let data = MockURLProtocol.mockData {
            client?.urlProtocol(self, didLoad: data)
        }
        
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
    
    static func reset() {
        mockData = nil
        mockResponse = nil
        mockError = nil
    }
}

// MARK: - Mock Models for Testing
struct MockModel: Codable, Equatable {
    let id: Int
    let name: String
}

// MARK: - APIService Tests
final class APIServiceTests: XCTestCase {
    var apiService: APIService!
    var mockSession: URLSession!
    
    override func setUp() {
        super.setUp()
        apiService = APIService.shared
        
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        mockSession = URLSession(configuration: configuration)
        
        // Inject mock session into APIService
        APIService.shared.urlSession = mockSession
    }
    
    override func tearDown() {
        MockURLProtocol.reset()
        apiService = nil
        mockSession = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    private func createMockResponse(statusCode: Int, url: String = "https://api.example.com/test") -> HTTPURLResponse {
        return HTTPURLResponse(
            url: URL(string: url)!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }
    
    private func encodeToData<T: Encodable>(_ object: T) -> Data {
        return try! JSONEncoder().encode(object)
    }
    
    // MARK: - fetch<T> Tests
    
    func testFetch_Success_ShouldReturnDecodedModel() async throws {
        // Given
        let mockModel = MockModel(id: 1, name: "Test")
        let mockData = encodeToData(mockModel)
        
        MockURLProtocol.mockData = mockData
        MockURLProtocol.mockResponse = createMockResponse(statusCode: 200)
        
        // When
        let result: MockModel = try await apiService.fetch(endpoint: "/test")
        
        // Then
        XCTAssertEqual(result, mockModel)
    }
    
    func testFetch_Success_WithArray_ShouldReturnDecodedArray() async throws {
        // Given
        let mockArray = [
            MockModel(id: 1, name: "Test1"),
            MockModel(id: 2, name: "Test2")
        ]
        let mockData = encodeToData(mockArray)
        
        MockURLProtocol.mockData = mockData
        MockURLProtocol.mockResponse = createMockResponse(statusCode: 200)
        
        // When
        let result: [MockModel] = try await apiService.fetch(endpoint: "/test")
        
        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].id, 1)
        XCTAssertEqual(result[1].name, "Test2")
    }
    
    func testFetch_InvalidURL_ShouldThrowInvalidURLError() async {
        do {
            let _: MockModel = try await apiService.fetch(endpoint: "%%%invalid%%%")
            XCTFail("Should throw invalidURL error")
        } catch let error as APIError {
            XCTAssertEqual(error.localizedDescription, APIError.invalidURL.localizedDescription)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - fetchTransactions Tests
    func testFetchTransactions_Success_ShouldReturnTransactions() async throws {
        // Given
        let mockTransactions = [
            Transaction(
                id: "1",
                date: "2024-01-15T10:30:00Z",
                transactionAmount: "100.00",
                transactionType: "transfer",
                description: "Test transaction",
                isDebit: true
            )
        ]
        let mockResponse = TransactionsResponse(
            transactions: mockTransactions,
            totalCount: 1,
            nextPage: 2
        )
        let mockData = encodeToData(mockResponse)
        
        MockURLProtocol.mockData = mockData
        MockURLProtocol.mockResponse = createMockResponse(statusCode: 200)
        
        // When
        let result = try await apiService.fetchTransactions(accountId: "123", nextPage: 1)
        
        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].id, "1")
        XCTAssertEqual(result[0].transactionAmount, "100.00")
        XCTAssertEqual(result[0].isDebit, true)
    }
    
    func testFetchTransactions_EmptyResponse_ShouldReturnEmptyArray() async throws {
        // Given
        let mockResponse = TransactionsResponse(
            transactions: nil,
            totalCount: 0,
            nextPage: nil
        )
        let mockData = encodeToData(mockResponse)
        
        MockURLProtocol.mockData = mockData
        MockURLProtocol.mockResponse = createMockResponse(statusCode: 200)
        
        // When
        let result = try await apiService.fetchTransactions(accountId: "123", nextPage: 1)
        
        // Then
        XCTAssertTrue(result.isEmpty)
    }
    
    func testFetchTransactions_WithDateFilters_ShouldIncludeDatesInBody() async throws {
        // Given
        let mockTransactions: [Transaction] = []
        let mockResponse = TransactionsResponse(
            transactions: mockTransactions,
            totalCount: 0,
            nextPage: nil
        )
        let mockData = encodeToData(mockResponse)
        
        MockURLProtocol.mockData = mockData
        MockURLProtocol.mockResponse = createMockResponse(statusCode: 200)
        
        // When
        let result = try await apiService.fetchTransactions(
            accountId: "123",
            nextPage: 2,
            fromDate: "2024-01-01T00:00:00Z",
            toDate: "2024-01-31T23:59:59Z"
        )
        
        // Then
        XCTAssertTrue(result.isEmpty)
    }
    
    func testFetchTransactions_StatusCode401_ShouldThrowUnauthorized() async {
        // Given
        MockURLProtocol.mockData = Data()
        MockURLProtocol.mockResponse = createMockResponse(statusCode: 401)
        
        // When/Then
        do {
            let _ = try await apiService.fetchTransactions(accountId: "123")
            XCTFail("Should throw unauthorized")
        } catch let error as APIError {
            XCTAssertEqual(error.localizedDescription, APIError.unauthorized.localizedDescription)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testFetchTransactions_NetworkError_ShouldThrowNetworkError() async {
        // Given
        MockURLProtocol.mockError = NSError(domain: NSURLErrorDomain, code: -1009, userInfo: nil)
        
        // When/Then
        do {
            let _ = try await apiService.fetchTransactions(accountId: "123")
            XCTFail("Should throw networkError")
        } catch let error as APIError {
            switch error {
            case .networkError:
                XCTAssertTrue(true)
            default:
                XCTFail("Expected networkError, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - APIError Tests
    
    func testAPIError_InvalidURL_LocalizedDescription() {
        let error = APIError.invalidURL
        XCTAssertEqual(error.localizedDescription, "Invalid URL")
    }
    
    func testAPIError_NoData_LocalizedDescription() {
        let error = APIError.noData
        XCTAssertEqual(error.localizedDescription, "No data received")
    }
    
    func testAPIError_DecodingError_LocalizedDescription() {
        let error = APIError.decodingError
        XCTAssertEqual(error.localizedDescription, "Error processing data")
    }
    
    func testAPIError_LimitExceeded_LocalizedDescription() {
        let error = APIError.limitExceeded
        XCTAssertEqual(error.localizedDescription, "Daily request limit reached")
    }
    
    func testAPIError_ServerNotFound_LocalizedDescription() {
        let error = APIError.serverNotFound
        XCTAssertEqual(error.localizedDescription, "Server not found. Check your connection.")
    }
    
    func testAPIError_Unauthorized_LocalizedDescription() {
        let error = APIError.unauthorized
        XCTAssertEqual(error.localizedDescription, "Authentication error")
    }
    
    func testAPIError_NetworkError_LocalizedDescription() {
        let nsError = NSError(domain: "test", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test network error"])
        let error = APIError.networkError(nsError)
        XCTAssertEqual(error.localizedDescription, "Test network error")
    }
}
