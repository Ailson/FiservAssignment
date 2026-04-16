//
//  FiservAssignmentApp.swift
//  FiservAssignment
//
//  Created by Ailson Cordeiro Filho on 14/04/26.
//	

import SwiftUI

@main
struct FiservAssignmentApp: App {
    @StateObject private var accountsViewModel = AccountsViewModel()
    
    var body: some Scene {
        WindowGroup {
            AccountsListView()
                .environmentObject(accountsViewModel)
        }
    }
}
