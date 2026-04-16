//
//  AccountModelTests.swift
//  FiservAssignmentTests
//
//  Created by Ailson Cordeiro Filho on 15/04/26.
//

import XCTest
@testable import FiservAssignment

final class AccountModelTests: XCTestCase {
    
    // MARK: - Test 1: Decodificação de JSON válido
    func testDecode_ValidJSON_ShouldReturnAccount() throws {
        // Given
        let json = """
        {
            "id": "1f34c76a-b3d1-43bc-af91-a82716f1bc2e",
            "account_number": 12345,
            "balance": "99.00",
            "currency_code": "EUR",
            "account_type": "current",
            "account_nickname": "My Salary"
        }
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let account = try decoder.decode(Account.self, from: json)
        
        // Then
        XCTAssertEqual(account.id, "1f34c76a-b3d1-43bc-af91-a82716f1bc2e")
        XCTAssertEqual(account.accountNumber, 12345)
        XCTAssertEqual(account.balance, "99.00")
        XCTAssertEqual(account.currency, "EUR")
        XCTAssertEqual(account.accountType, "current")
        XCTAssertEqual(account.nickname, "My Salary")
    }
    
    // MARK: - Test 2: Nickname nulo
    func testDecode_NullNickname_ShouldReturnNil() throws {
        // Given
        let json = """
        {
            "id": "d991edab-989f-44f9-bff9-ed4ed46a0e86",
            "account_number": 54321,
            "balance": "2316.00",
            "currency_code": "GBP",
            "account_type": "current",
            "account_nickname": null
        }
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let account = try decoder.decode(Account.self, from: json)
        
        // Then
        XCTAssertNil(account.nickname)
    }
    
    // MARK: - Test 3: Array de contas
    func testDecode_ValidArray_ShouldReturnAccounts() throws {
        // Given
        let json = """
        [
            {
                "id": "1",
                "account_number": 12345,
                "balance": "99.00",
                "currency_code": "EUR",
                "account_type": "current",
                "account_nickname": "Account 1"
            },
            {
                "id": "2",
                "account_number": 67890,
                "balance": "500.00",
                "currency_code": "USD",
                "account_type": "savings",
                "account_nickname": null
            }
        ]
        """.data(using: .utf8)!
        
        // When
        let decoder = JSONDecoder()
        let accounts = try decoder.decode([Account].self, from: json)
        
        // Then
        XCTAssertEqual(accounts.count, 2)
        XCTAssertEqual(accounts[0].id, "1")
        XCTAssertEqual(accounts[1].id, "2")
    }
    
    // MARK: - Test 4: displayName com nickname
    func testDisplayName_WithNickname_ShouldReturnNickname() {
        // Given
        let account = Account(
            id: "1",
            accountNumber: 12345,
            nickname: "My Salary",
            accountType: "current",
            balance: "99.00",
            currency: "EUR"
        )
        
        // When
        let displayName = account.displayName
        
        // Then
        XCTAssertEqual(displayName, "My Salary")
    }
    
    // MARK: - Test 5: displayName sem nickname
    func testDisplayName_WithoutNickname_ShouldReturnAccountNumber() {
        // Given
        let account = Account(
            id: "1",
            accountNumber: 54321,
            nickname: nil,
            accountType: "savings",
            balance: "2316.00",
            currency: "GBP"
        )
        
        // When
        let displayName = account.displayName
        
        // Then
        XCTAssertEqual(displayName, "54321")
    }
    
    // MARK: - Test 6: displayName com nickname vazio
    func testDisplayName_WithEmptyNickname_ShouldReturnAccountNumber() {
        // Given
        let account = Account(
            id: "1",
            accountNumber: 98765,
            nickname: "",
            accountType: "current",
            balance: "100.00",
            currency: "EUR"
        )
        
        // When
        let displayName = account.displayName
        
        // Then
        XCTAssertEqual(displayName, "98765")
    }
    
    // MARK: - Test 7: formattedBalance - EUR
    func testFormattedBalance_EUR_ShouldFormatCorrectly() {
        // Given
        let account = Account(
            id: "1",
            accountNumber: 12345,
            nickname: "Test",
            accountType: "current",
            balance: "99.00",
            currency: "EUR"
        )
        
        // When
        let formatted = account.formattedBalance
        
        // Then
        XCTAssertTrue(formatted.contains("€") || formatted.contains("EUR"))
        XCTAssertTrue(formatted.contains("99.00") || formatted.contains("99,00"))
    }
}
