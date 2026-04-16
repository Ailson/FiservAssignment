//
//  AccountRowView.swift
//  FiservAssignment
//
//  Created by Ailson Cordeiro Filho on 14/04/26.
//
import SwiftUI

struct AccountRowView: View {
    let account: Account
    let isFavorite: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(accountTypeColor.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: accountTypeIcon)
                    .foregroundColor(accountTypeColor)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(account.displayName)
                        .font(.headline)
                    
                    if isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
                
                Text(account.accountType)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(account.formattedBalance)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
    
    private var accountTypeIcon: String {
        switch account.accountType.lowercased() {
        case _ where account.accountType.lowercased().contains("current"):
            return "dollarsign.circle"
        case _ where account.accountType.lowercased().contains("savings"):
            return "lock.circle"
        case _ where account.accountType.lowercased().contains("time"):
            return "chart.line.uptrend.xyaxis.circle"
        default:
            return "creditcard.circle"
        }
    }
    
    private var accountTypeColor: Color {
        switch account.accountType.lowercased() {
        case _ where account.accountType.lowercased().contains("current"):
            return .blue
        case _ where account.accountType.lowercased().contains("savings"):
            return .green
        case _ where account.accountType.lowercased().contains("time"):
            return .purple
        default:
            return .gray
        }
    }
}

// MARK: - Preview
struct AccountRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            AccountRowView(
                account: Account(
                    id: "1",
                    accountNumber: 12345678,
                    nickname: "Conta Principal",
                    accountType: "Conta Corrente",
                    balance: "5432.10",
                    currency: "BRL"
                ),
                isFavorite: true
            )
            
            AccountRowView(
                account: Account(
                    id: "2",
                    accountNumber: 87654321,
                    nickname: nil,
                    accountType: "Poupança",
                    balance: "15000.00",
                    currency: "BRL"
                ),
                isFavorite: false
            )
        }
        .listStyle(.plain)
    }
}
