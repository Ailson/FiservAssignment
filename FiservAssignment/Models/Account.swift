//
//  Account.swift
//  FiservAssignment
//
//  Created by Ailson Cordeiro Filho on 14/04/26.
//
import Foundation

struct Account: Codable, Identifiable {
    let id: String
    let accountNumber: Int
    let nickname: String?
    let accountType: String
    let balance: String
    let currency: String
    
    var displayName: String {
        if let nickname = nickname, !nickname.isEmpty {
            return nickname
        }
        return String(accountNumber)
    }
    
    var formattedBalance: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: balanceValue)) ?? "\(currency) \(balanceValue)"
    }
    
    var balanceValue: Double {
        return Double(balance) ?? 0.0
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case accountNumber = "account_number"
        case nickname = "account_nickname"
        case accountType = "account_type"
        case balance
        case currency = "currency_code"
    }
}
