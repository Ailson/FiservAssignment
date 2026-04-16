//
//  AccountDetail.swift
//  FiservAssignment
//
//  Created by Ailson Cordeiro Filho on 14/04/26.
//

import Foundation

struct AccountDetailResponse: Codable {
    let productName: String?
    let openedDate: String?
    let branch: String?
    let beneficiaries: [String]?
    
    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case openedDate = "opened_date"
        case branch
        case beneficiaries
    }
}

struct AccountDetail {
    let id: String
    let accountNumber: Int
    let nickname: String?
    let accountType: String
    let balance: String
    let currency: String
    let productName: String?
    let openedDate: String?
    let branch: String?
    let beneficiaries: [String]?
    
    var displayName: String {
        if let nickname = nickname, !nickname.isEmpty {
            return nickname
        }
        return String(accountNumber)
    }
    
    var formattedBalance: String {
        guard let balanceValue = Double(balance) else {
            return "\(currency) \(balance)"
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: balanceValue)) ?? "\(currency) \(balance)"
    }
}
