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
    
    private var nextPage = 1
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
            
            print("📍 Fetching transactions...")
            transactions = try await apiService.fetchTransactions(
                accountId: accountId,
                nextPage: nextPage
            )
            print("✅ Transactions received: \(transactions.count)")
            
            nextPage += 1
            hasMorePages = !transactions.isEmpty
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
        guard !isLoadingMore && hasMorePages else { return }
        
        print("📍 Loading more transactions - page \(nextPage)")
        isLoadingMore = true
        paginationError = nil
        
        do {
            let newTransactions = try await apiService.fetchTransactions(
                accountId: accountId,
                nextPage: nextPage
            )
            
            if newTransactions.isEmpty {
                hasMorePages = false
                print("📍 No more transactions")
            } else {
                transactions.append(contentsOf: newTransactions)
                nextPage += 1
                print("✅ +\(newTransactions.count) transactions loaded")
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
