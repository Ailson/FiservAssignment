//
//  AccountDetailHeaderView.swift
//  FiservAssignment
//
//  Created by Ailson Cordeiro Filho on 14/04/26.
//

import SwiftUI

struct AccountDetailHeaderView: View {
    let detail: AccountDetail
    let isFavorite: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(detail.displayName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if isFavorite {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.title3)
                        }
                    }
                    
                    Text(detail.accountType.capitalized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Available Balance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(detail.formattedBalance)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
            }
            
            Divider()
            
            VStack(spacing: 12) {
                InfoRow(title: "Account Number", value: String(detail.accountNumber))
                InfoRow(title: "Product", value: detail.productName)
                InfoRow(title: "Opened Date", value: formatDate(detail.openedDate))
                InfoRow(title: "Branch", value: detail.branch)
            }
            
            if let beneficiaries = detail.beneficiaries, !beneficiaries.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Divider()
                    
                    Text("Beneficiaries")
                        .font(.headline)
                    
                    ForEach(beneficiaries, id: \.self) { beneficiary in
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.blue)
                            Text(beneficiary)
                                .font(.body)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
    
    private func formatDate(_ dateString: String?) -> String? {
        guard let dateString = dateString else { return nil }
        
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "dd/MM/yyyy"
            return outputFormatter.string(from: date)
        }
        
        return dateString
    }
}
// MARK: - Preview
struct AccountDetailHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        let detail = AccountDetail(
            id: "1f34c76a-b3d1-43bc-af91-a82716f1bc2e",
            accountNumber: 12345,
            nickname: "My Salary",
            accountType: "current",
            balance: "5432.10",
            currency: "EUR",
            productName: "Current Account EUR",
            openedDate: "2015-12-03T10:15:30Z",
            branch: "Main Branch - London",
            beneficiaries: ["John Doe", "Jane Smith", "Bob Johnson"]
        )
        
        return ScrollView {
            AccountDetailHeaderView(
                detail: detail,
                isFavorite: true
            )
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
    }
}

// Preview sem beneficiários
struct AccountDetailHeaderView_NoBeneficiaries_Previews: PreviewProvider {
    static var previews: some View {
        let detail = AccountDetail(
            id: "2",
            accountNumber: 54321,
            nickname: nil,
            accountType: "savings",
            balance: "15000.00",
            currency: "GBP",
            productName: "Savings Account",
            openedDate: "2018-06-15T10:15:30Z",
            branch: "Oxford Street Branch",
            beneficiaries: nil
        )
        
        return ScrollView {
            AccountDetailHeaderView(
                detail: detail,
                isFavorite: false
            )
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
    }
}

// Preview com dados mínimos (campos opcionais nil)
struct AccountDetailHeaderView_MinimalData_Previews: PreviewProvider {
    static var previews: some View {
        let detail = AccountDetail(
            id: "3",
            accountNumber: 98765,
            nickname: nil,
            accountType: "credit card",
            balance: "0.00",
            currency: "EUR",
            productName: nil,
            openedDate: nil,
            branch: nil,
            beneficiaries: []
        )
        
        return ScrollView {
            AccountDetailHeaderView(
                detail: detail,
                isFavorite: false
            )
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
    }
}

// Preview com saldo negativo
struct AccountDetailHeaderView_NegativeBalance_Previews: PreviewProvider {
    static var previews: some View {
        let detail = AccountDetail(
            id: "4",
            accountNumber: 34567,
            nickname: "Credit Card",
            accountType: "credit card",
            balance: "-250.50",
            currency: "EUR",
            productName: "Platinum Credit Card",
            openedDate: "2022-01-10T10:15:30Z",
            branch: "Online Banking",
            beneficiaries: nil
        )
        
        return ScrollView {
            AccountDetailHeaderView(
                detail: detail,
                isFavorite: false
            )
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
    }
}

// Preview Dark Mode
struct AccountDetailHeaderView_DarkMode_Previews: PreviewProvider {
    static var previews: some View {
        let detail = AccountDetail(
            id: "1",
            accountNumber: 12345,
            nickname: "My Salary",
            accountType: "current",
            balance: "5432.10",
            currency: "EUR",
            productName: "Current Account EUR",
            openedDate: "2015-12-03T10:15:30Z",
            branch: "Main Branch",
            beneficiaries: ["John Doe"]
        )
        
        return ScrollView {
            AccountDetailHeaderView(
                detail: detail,
                isFavorite: true
            )
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
        .preferredColorScheme(.dark)
    }
}
