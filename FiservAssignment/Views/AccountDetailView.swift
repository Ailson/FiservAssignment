//
//  AccountDetailView.swift
//  FiservAssignment
//
//  Created by Ailson Cordeiro Filho on 14/04/26.
//

import SwiftUI

struct AccountDetailView: View {
    let account: Account
    @StateObject private var viewModel = AccountDetailViewModel()
    @EnvironmentObject private var accountsViewModel: AccountsViewModel
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                loadingView
            } else if let error = viewModel.errorMessage {
                errorView(error: error)
            } else if let detail = viewModel.accountDetail {
                detailView(detail: detail)
            }
        }
        .navigationTitle("Account Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    accountsViewModel.toggleFavorite(accountId: account.id)
                } label: {
                    Image(systemName: accountsViewModel.favoriteIds.contains(account.id)
                          ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                }
            }
        }
        .onAppear {
            print("🎬 AccountDetailView.onAppear - accountId: \(account.id)")
            print("🌐 Starting fetchAccountDetail...")
            Task { await viewModel.fetchAccountDetail(accountId: account.id, baseAccount: account) }
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading account details...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    private func errorView(error: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Oops! Something went wrong")
                .font(.headline)
            
            Text(error)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Try Again") {
                Task { await viewModel.fetchAccountDetail(accountId: account.id, baseAccount: account) }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private func detailView(detail: AccountDetail) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                AccountDetailHeaderView(
                    detail: detail,
                    isFavorite: accountsViewModel.favoriteIds.contains(account.id)
                )
                
                TransactionsListView(
                    transactions: viewModel.transactions,
                    onLoadMore: {
                        Task {
                            await viewModel.loadMoreTransactions(accountId: account.id)
                        }
                    },
                    isLoadingMore: viewModel.isLoadingMore
                )
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Preview
struct AccountDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let accountsViewModel = AccountsViewModel()
        accountsViewModel.favoriteIds = ["12345"]
        
        let account = Account(id: "12345",
                              accountNumber: 12345,
                              nickname: "Test Account",
                              accountType: "Current",
                              balance: "1222.22",
                              currency: "EUR")
        
        return NavigationView {
            AccountDetailView(account: account)
                .environmentObject(accountsViewModel)
        }
    }
}

