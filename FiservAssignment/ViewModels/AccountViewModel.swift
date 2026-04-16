//
//  AccountsViewModel.swift
//  FiservAssignment
//
//  Created by Ailson Cordeiro Filho on 14/04/26.
//

import SwiftUI

@MainActor
class AccountsViewModel: ObservableObject {
    @Published var accounts: [Account] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var favoriteIds: Set<String> = []
    
    private let favoritesKey = "favoriteAccounts"
    private let apiService: APIService
    
    init(apiService: APIService = .shared) {
        self.apiService = apiService
        loadFavorites()
    }
    
    func fetchAccounts() async {
        isLoading = true
        errorMessage = nil
        
        await getAccounts()
        isLoading = false
    }
    
    func refresAccounts() async {
        await getAccounts(showErrors: false)
    }

    private func getAccounts(showErrors: Bool = true) async {
        do {
            accounts = try await apiService.fetch(endpoint: "/accounts")
        } catch let error{
            if showErrors {
                handleError(error: error)
            }
            
            print("❌ error:")
            print(error.localizedDescription)
        }
    }
    
    private func handleError(error: Error) {
        if let apiError = error as? APIError {
            switch apiError {
            case .serverNotFound:
                errorMessage = "Server not found. Check your internet connection."
            case .unauthorized:
                errorMessage = "Authentication error. Please verify your credentials."
            case .limitExceeded:
                errorMessage = "Daily request limit reached. Please try again tomorrow."
            default:
                errorMessage = error.localizedDescription
            }
        } else {
            let nsError = error as NSError
            if nsError.domain == NSURLErrorDomain && nsError.code == -1001 {
                errorMessage = "Request timed out. Please try again."
            } else {
                errorMessage = "Unexpected error: \(error.localizedDescription)"
            }
        }
    }
    
    func toggleFavorite(accountId: String) {
        if favoriteIds.contains(accountId) {
            favoriteIds.remove(accountId)
        } else {
            favoriteIds.insert(accountId)
        }
        saveFavorites()
    }
    
    private func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: favoritesKey),
           let ids = try? JSONDecoder().decode(Set<String>.self, from: data) {
            favoriteIds = ids
        }
    }
    
    private func saveFavorites() {
        if let data = try? JSONEncoder().encode(favoriteIds) {
            UserDefaults.standard.set(data, forKey: favoritesKey)
        }
    }
}
