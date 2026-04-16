//
//  Transaction.swift
//  FiservAssignment
//
//  Created by Ailson Cordeiro Filho on 14/04/26.
//

import Foundation

struct Transaction: Codable, Identifiable {
    let id: String
    let date: String
    let transactionAmount: String
    let transactionType: String
    let description: String?
    let isDebit: Bool
    
    var amount: Double {
        return Double(transactionAmount) ?? 0.0
    }
    
    var currency: String {
        return "EUR"
    }
    
    var type: TransactionType {
        return isDebit ? .debit : .credit
    }
    
    var displayDescription: String {
        return description ?? transactionType.capitalized
    }
    
    var formattedAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        
        let amountValue = Double(transactionAmount) ?? 0.0
        let formatted = formatter.string(from: NSNumber(value: amountValue)) ?? "\(currency) \(transactionAmount)"
        
        return isDebit ? "- \(formatted)" : "+ \(formatted)"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case date
        case transactionAmount = "transaction_amount"
        case transactionType = "transaction_type"
        case description
        case isDebit = "is_debit"
    }
}

enum TransactionType {
    case credit
    case debit
}

struct TransactionsResponse: Codable {
    let transactions: [Transaction]?
    let paging: Paging
}

struct Paging: Codable {
    let pagesCount: Int
    let totalItems: Int
    let currentPage: Int
    
    enum CodingKeys: String, CodingKey {
        case pagesCount = "pages_count"
        case totalItems = "total_items"
        case currentPage = "current_page"
    }
}
