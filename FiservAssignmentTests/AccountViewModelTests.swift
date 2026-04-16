//
//  AccountsViewModelTests.swift
//  FiservAssignmentTests
//
//  Created by Ailson Cordeiro Filho on 15/04/26.
//

import XCTest
@testable import FiservAssignment

// MARK: - Mock APIService
class MockAPIServiceForAccounts: APIService {
    var mockAccounts: [Account] = []
    var mockError: Error?
    var shouldSucceed = true
    var fetchCallCount = 0
    var lastEndpoint: String?
    
    override func fetch<T: Decodable>(endpoint: String) async throws -> T {
        fetchCallCount += 1
        lastEndpoint = endpoint
        
        if shouldSucceed {
            return mockAccounts as! T
        } else {
            throw mockError ?? APIError.networkError(NSError(domain: "", code: -1))
        }
    }
}

// MARK: - AccountsViewModel Tests
@MainActor
final class AccountsViewModelTests: XCTestCase {
    var viewModel: AccountsViewModel!
    var mockAPIService: MockAPIServiceForAccounts!
    
    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIServiceForAccounts()
        
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
        
        viewModel = AccountsViewModel(apiService: mockAPIService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockAPIService = nil
        UserDefaults.standard.removeObject(forKey: "favoriteAccounts")
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    private func createMockAccounts() -> [Account] {
        return [
            Account(
                id: "1",
                accountNumber: 12345,
                nickname: "My Salary",
                accountType: "current",
                balance: "99.00",
                currency: "EUR"
            ),
            Account(
                id: "2",
                accountNumber: 54321,
                nickname: nil,
                accountType: "savings",
                balance: "2316.00",
                currency: "GBP"
            ),
            Account(
                id: "3",
                accountNumber: 98765,
                nickname: "Retirement",
                accountType: "time",
                balance: "50000.00",
                currency: "EUR"
            )
        ]
    }
    
    // MARK: - fetchAccounts Tests
    
    func testFetchAccounts_Success_ShouldPopulateAccounts() async {
        // Given
        let mockAccounts = createMockAccounts()
        mockAPIService.mockAccounts = mockAccounts
        mockAPIService.shouldSucceed = true
        
        // When
        await viewModel.fetchAccounts()
        
        // Then
        XCTAssertEqual(viewModel.accounts.count, 3)
        XCTAssertEqual(viewModel.accounts[0].id, "1")
        XCTAssertEqual(viewModel.accounts[1].displayName, "54321")
        XCTAssertEqual(viewModel.accounts[2].nickname, "Retirement")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(mockAPIService.fetchCallCount, 1)
        XCTAssertEqual(mockAPIService.lastEndpoint, "/accounts")
    }
    
    func testFetchAccounts_Success_EmptyList_ShouldSetEmptyAccounts() async {
        // Given
        mockAPIService.mockAccounts = []
        mockAPIService.shouldSucceed = true
        
        // When
        await viewModel.fetchAccounts()
        
        // Then
        XCTAssertTrue(viewModel.accounts.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchAccounts_ServerNotFound_ShouldSetErrorMessage() async {
        // Given
        mockAPIService.shouldSucceed = false
        mockAPIService.mockError = APIError.serverNotFound
        
        // When
        await viewModel.fetchAccounts()
        
        // Then
        XCTAssertTrue(viewModel.accounts.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.errorMessage, "Server not found. Check your internet connection.")
    }
    
    func testFetchAccounts_Unauthorized_ShouldSetErrorMessage() async {
        // Given
        mockAPIService.shouldSucceed = false
        mockAPIService.mockError = APIError.unauthorized
        
        // When
        await viewModel.fetchAccounts()
        
        // Then
        XCTAssertTrue(viewModel.accounts.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.errorMessage, "Authentication error. Please verify your credentials.")
    }
    
    func testFetchAccounts_LimitExceeded_ShouldSetErrorMessage() async {
        // Given
        mockAPIService.shouldSucceed = false
        mockAPIService.mockError = APIError.limitExceeded
        
        // When
        await viewModel.fetchAccounts()
        
        // Then
        XCTAssertTrue(viewModel.accounts.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.errorMessage, "Daily request limit reached. Please try again tomorrow.")
    }
    
    func testFetchAccounts_Timeout_ShouldSetTimeoutMessage() async {
        // Given
        mockAPIService.shouldSucceed = false
        mockAPIService.mockError = NSError( domain: NSURLErrorDomain,
            code: -1001,
            userInfo: [NSLocalizedDescriptionKey: "The request timed out."]
        )
        
        // When
        await viewModel.fetchAccounts()
        
        // Then
        XCTAssertTrue(viewModel.accounts.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.errorMessage, "Request timed out. Please try again.")
    }
    
    func testRetryFetchAccounts_ShouldCallFetchAgain() async {
        // Given
        mockAPIService.shouldSucceed = false
        mockAPIService.mockError = APIError.serverNotFound
        
        await viewModel.fetchAccounts()
        XCTAssertEqual(mockAPIService.fetchCallCount, 1)
        XCTAssertNotNil(viewModel.errorMessage)
        
        // When - Retry with success
        mockAPIService.shouldSucceed = true
        mockAPIService.mockAccounts = createMockAccounts()
        await viewModel.retryFetchAccounts()
        
        // Then
        XCTAssertEqual(mockAPIService.fetchCallCount, 2)
        XCTAssertEqual(viewModel.accounts.count, 3)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // MARK: - Favorites Tests
    
    func testToggleFavorite_AddFavorite_ShouldAddToFavorites() {
        // Given
        let accountId = "test-123"
        
        // When
        viewModel.toggleFavorite(accountId: accountId)
        
        // Then
        XCTAssertTrue(viewModel.favoriteIds.contains(accountId))
        XCTAssertEqual(viewModel.favoriteIds.count, 1)
    }
    
    func testToggleFavorite_RemoveFavorite_ShouldRemoveFromFavorites() {
        // Given
        let accountId = "test-123"
        viewModel.toggleFavorite(accountId: accountId)
        XCTAssertTrue(viewModel.favoriteIds.contains(accountId))
        
        // When
        viewModel.toggleFavorite(accountId: accountId)
        
        // Then
        XCTAssertFalse(viewModel.favoriteIds.contains(accountId))
        XCTAssertTrue(viewModel.favoriteIds.isEmpty)
    }
    
    func testFavoritesPersistence_SaveAndLoad_ShouldPersistCorrectly() {
        // Given
        let account1 = "persist-1"
        let account2 = "persist-2"
        
        // When - Save favorites
        viewModel.toggleFavorite(accountId: account1)
        viewModel.toggleFavorite(accountId: account2)
        
        // Then - Verify saved to UserDefaults
        let savedData = UserDefaults.standard.data(forKey: "favoriteAccounts")
        XCTAssertNotNil(savedData)
        
        // When - Create new ViewModel (simulates app restart)
        let newViewModel = AccountsViewModel(apiService: mockAPIService)
        
        // Then - Favorites should be loaded
        XCTAssertEqual(newViewModel.favoriteIds.count, 2)
        XCTAssertTrue(newViewModel.favoriteIds.contains(account1))
        XCTAssertTrue(newViewModel.favoriteIds.contains(account2))
    }
}
