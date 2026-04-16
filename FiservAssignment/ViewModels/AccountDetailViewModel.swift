//
//  AccountDetailViewModel.swift
//  FiservAssignment
//
//  Created by Ailson Cordeiro Filho on 14/04/26.
//

import Foundation
import SwiftUI

@MainActor
class AccountDetailViewModel: ObservableObject {
    @Published var accountDetail: AccountDetail?
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var paginationError: String?
    
    private var nextPage = 0
    private var hasMorePages = true
    private var hasLoaded = false
    
    private let apiService: APIService
    
    init(apiService: APIService = .shared) {
        self.apiService = apiService
    }
    
    func fetchAccountDetail(accountId: String, baseAccount: Account) async {
        guard !hasLoaded else { return }
        
        print("🔄 fetchAccountDetail STARTED for: \(accountId)")
        isLoading = true
        errorMessage = nil
        
        do {
            let endpoint = "/account/details/\(accountId)"
            print("📍 Fetching additional details: \(endpoint)")
            
            let detailsResponse: AccountDetailResponse = try await apiService.fetch(endpoint: endpoint)
            print("✅ Additional details received")
            
            accountDetail = AccountDetail(
                id: baseAccount.id,
                accountNumber: baseAccount.accountNumber,
                nickname: baseAccount.nickname,
                accountType: baseAccount.accountType,
                balance: baseAccount.balance,
                currency: baseAccount.currency,
                productName: detailsResponse.productName,
                openedDate: detailsResponse.openedDate,
                branch: detailsResponse.branch,
                beneficiaries: detailsResponse.beneficiaries
            )
            
            print("✅ Combined AccountDetail created")
            
            print("🔄 Fetching transactions...")
            let transactionsResponse = try await apiService.fetchTransactions(accountId: accountId, nextPage: nextPage)
            transactions = transactionsResponse.transactions ?? []
            print("✅ Transactions received: \(transactions.count)")
            
            nextPage += 1
            hasMorePages = nextPage < transactionsResponse.paging.pagesCount
            hasLoaded = true
            
        } catch let error as APIError {
            print("❌ API Error: \(error)")
            errorMessage = error.localizedDescription
            accountDetail = nil
            transactions = []
        } catch {
            print("❌ ERROR in fetchAccountDetail: \(error)")
            errorMessage = "Error loading: \(error.localizedDescription)"
            accountDetail = nil
            transactions = []
        }
        
        isLoading = false
        print("🏁 fetchAccountDetail FINISHED")
    }
    
    func loadMoreTransactions(accountId: String) async {
        guard !isLoadingMore && hasMorePages else {
            print("📍 No more transactions")
            return
        }
        
        print("📍 Loading more transactions - page \(nextPage)")
        isLoadingMore = true
        paginationError = nil
        
        do {
            let transactionsResponse = try await apiService.fetchTransactions(accountId: accountId, nextPage: nextPage)
            if let newTransactions = transactionsResponse.transactions {
                transactions.append(contentsOf: newTransactions)
                print("✅ +\(newTransactions.count) transactions loaded")
                nextPage += 1
            }
            
            if nextPage < transactionsResponse.paging.pagesCount {
                hasMorePages = true
            } else {
                hasMorePages = false
                print("📍 No more transactions")
            }
        } catch {
            print("❌ Error loading more: \(error)")
            hasMorePages = false
        }
        
        isLoadingMore = false
    }
    
    func dismissPaginationError() {
        paginationError = nil
    }
}
