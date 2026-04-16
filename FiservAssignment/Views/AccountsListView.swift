//
//  AccountsListView.swift
//  FiservAssignment
//
//  Created by Ailson Cordeiro Filho on 14/04/26.
//

import SwiftUI

struct AccountsListView: View {
    @EnvironmentObject private var viewModel: AccountsViewModel
    
    var body: some View {
        NavigationView {
            contentView
            .navigationTitle("My Accounts")
        }
        .navigationViewStyle(.stack)
        .task {
            await viewModel.fetchAccounts()
        }
    }
    
    // MARK: - Component Views
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            loadingView
        } else if let error = viewModel.errorMessage {
            errorView(error: error)
        } else if viewModel.accounts.isEmpty {
            emptyView
        } else {
            accountsList
        }
    }
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading accounts...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.text.rectangle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No accounts found")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("Pull to refresh to try again")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var accountsList: some View {
        List(viewModel.accounts) { account in
            NavigationLink {
                AccountDetailView(account: account)
            } label: {
                AccountRowView(
                    account: account,
                    isFavorite: viewModel.favoriteIds.contains(account.id)
                )
            }
        }
        .listStyle(.plain)
        .refreshable {
            await viewModel.refresAccounts()
        }
    }
    
    private func errorView(error: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Oops! Something went wrong")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(error)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                Task {
                    await viewModel.fetchAccounts()
                }
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Try Again")
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
    }
}

// MARK: - Preview
struct AccountsListView_Previews: PreviewProvider {
    static var previews: some View {
        return AccountsListView().environmentObject(AccountsViewModel())
    }
}
