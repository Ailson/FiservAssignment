//
//  AccountDetailViewModelTests.swift
//  FiservAssignmentTests
//
//  Created by Ailson Cordeiro Filho on 15/04/26.
//

import XCTest
@testable import FiservAssignment

// MARK: - Mock APIService that throws
class MockAPIServiceForDetail: APIService {
    var mockAccountDetailResponse: AccountDetailResponse?
    var mockTransactions: [Transaction] = []
    var mockError: APIError?
    
    var fetchDetailShouldThrow = false
    var fetchTransactionsShouldThrow = false
    
    var fetchDetailCallCount = 0
    var fetchTransactionsCallCount = 0
    var lastTransactionsPage: Int?
    
    override func fetch<T: Decodable>(endpoint: String) async throws -> T {
        fetchDetailCallCount += 1
        
        if fetchDetailShouldThrow {
            throw mockError ?? .networkError(NSError(domain: "", code: -1))
        }
        
        guard let response = mockAccountDetailResponse else {
            throw APIError.noData
        }
        return response as! T
    }
    
    override func fetchTransactions(
        accountId: String,
        nextPage: Int,
        fromDate: String?,
        toDate: String?
    ) async throws -> [Transaction] {
        fetchTransactionsCallCount += 1
        lastTransactionsPage = nextPage
        
        if fetchTransactionsShouldThrow {
            throw mockError ?? .networkError(NSError(domain: "", code: -1))
        }
        
        return mockTransactions
    }
}

// MARK: - AccountDetailViewModel Tests
@MainActor
final class AccountDetailViewModelTests: XCTestCase {
    var viewModel: AccountDetailViewModel!
    var mockAPIService: MockAPIServiceForDetail!
    var baseAccount: Account!
    
    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIServiceForDetail()
        viewModel = AccountDetailViewModel(apiService: mockAPIService)
        
        baseAccount = Account(
            id: "1",
            accountNumber: 12345,
            nickname: "My Salary",
            accountType: "current",
            balance: "99.00",
            currency: "EUR"
        )
    }
    
    override func tearDown() {
        viewModel = nil
        mockAPIService = nil
        baseAccount = nil
        super.tearDown()
    }
    
    // MARK: - fetchAccountDetail Tests
    
    func testFetchAccountDetail_Success_ShouldCombineData() async {
        // Given
        mockAPIService.mockAccountDetailResponse = AccountDetailResponse(
            productName: "Current Account",
            openedDate: "2020-01-01T00:00:00Z",
            branch: "Main Branch",
            beneficiaries: ["John Doe"]
        )
        mockAPIService.mockTransactions = [
            Transaction(id: "1", date: "2024-01-01T00:00:00Z", transactionAmount: "100.00",
                       transactionType: "transfer", description: "Test", isDebit: true)
        ]
        
        // When
        await viewModel.fetchAccountDetail(accountId: "1", baseAccount: baseAccount)
        
        // Then
        XCTAssertNotNil(viewModel.accountDetail)
        XCTAssertEqual(viewModel.accountDetail?.productName, "Current Account")
        XCTAssertEqual(viewModel.transactions.count, 1)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchAccountDetail_DetailAPIFails_ShouldSetError() async {
        // Given
        mockAPIService.fetchDetailShouldThrow = true
        mockAPIService.mockError = .serverNotFound
        
        // When
        await viewModel.fetchAccountDetail(accountId: "1", baseAccount: baseAccount)
        
        // Then
        XCTAssertNil(viewModel.accountDetail)
        XCTAssertTrue(viewModel.transactions.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNotNil(viewModel.errorMessage)
    }
    
    func testFetchAccountDetail_WithHasLoadedTrue_ShouldNotFetchAgain() async {
        // Given
        mockAPIService.mockAccountDetailResponse = AccountDetailResponse(
            productName: "Test", openedDate: nil, branch: nil, beneficiaries: nil
        )
        
        // When - First call
        await viewModel.fetchAccountDetail(accountId: "1", baseAccount: baseAccount)
        let firstCallCount = mockAPIService.fetchDetailCallCount
        
        // When - Second call
        await viewModel.fetchAccountDetail(accountId: "1", baseAccount: baseAccount)
        
        // Then
        XCTAssertEqual(mockAPIService.fetchDetailCallCount, firstCallCount)
    }
    
    // MARK: - loadMoreTransactions Tests
    
    func testLoadMoreTransactions_Success_ShouldAppendTransactions() async {
        // Given
        mockAPIService.mockAccountDetailResponse = AccountDetailResponse(
            productName: "Test", openedDate: nil, branch: nil, beneficiaries: nil
        )
        mockAPIService.mockTransactions = [
            Transaction(id: "1", date: "2024-01-01T00:00:00Z", transactionAmount: "100.00",
                       transactionType: "transfer", description: "First", isDebit: true)
        ]
        
        await viewModel.fetchAccountDetail(accountId: "1", baseAccount: baseAccount)
        XCTAssertEqual(viewModel.transactions.count, 1)
        
        // When - Load more
        mockAPIService.mockTransactions = [
            Transaction(id: "2", date: "2024-01-02T00:00:00Z", transactionAmount: "200.00",
                       transactionType: "deposit", description: "Second", isDebit: false)
        ]
        await viewModel.loadMoreTransactions(accountId: "1")
        
        // Then
        XCTAssertEqual(viewModel.transactions.count, 2)
        XCTAssertEqual(viewModel.transactions[1].id, "2")
        XCTAssertFalse(viewModel.isLoadingMore)
    }
    
    func testLoadMoreTransactions_Error_ShouldSetPaginationError() async {
        // Given
        mockAPIService.mockAccountDetailResponse = AccountDetailResponse(
            productName: "Test", openedDate: nil, branch: nil, beneficiaries: nil
        )
        mockAPIService.mockTransactions = [
            Transaction(id: "1", date: "2024-01-01T00:00:00Z", transactionAmount: "100.00",
                       transactionType: "transfer", description: "Test", isDebit: true)
        ]
        
        await viewModel.fetchAccountDetail(accountId: "1", baseAccount: baseAccount)
        
        // When - Error on load more
        mockAPIService.fetchTransactionsShouldThrow = true
        await viewModel.loadMoreTransactions(accountId: "1")
        
        // Then
        XCTAssertNotNil(viewModel.paginationError)
        XCTAssertFalse(viewModel.isLoadingMore)
    }
    
    // MARK: - dismissPaginationError Test
    
    func testDismissPaginationError_ShouldClearError() {
        // Given
        viewModel.paginationError = "Some error"
        
        // When
        viewModel.dismissPaginationError()
        
        // Then
        XCTAssertNil(viewModel.paginationError)
    }
}
