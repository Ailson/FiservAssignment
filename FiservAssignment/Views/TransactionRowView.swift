//
//  TransactionRowView.swift
//  FiservAssignment
//
//  Created by Ailson Cordeiro Filho on 14/04/26.
//
import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(transaction.isDebit ? Color.red.opacity(0.2) : Color.green.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: transaction.isDebit ? "arrow.up.right" : "arrow.down.left")
                    .foregroundColor(transaction.isDebit ? .red : .green)
                    .font(.system(size: 16, weight: .bold))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.displayDescription)
                    .font(.body)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Text(formatDate(transaction.date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(transaction.transactionType.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(transaction.formattedAmount)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(transaction.isDebit ? .red : .green)
        }
        .padding()
    }
    
    private func formatDate(_ dateString: String) -> String {
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
struct TransactionRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            TransactionRowView(
                transaction: Transaction(
                    id: "1",
                    date: "2024-01-15T10:30:00Z",
                    transactionAmount: "5000.00",
                    transactionType: "salary",
                    description: "Salário",
                    isDebit: false
                )
            )
            
            TransactionRowView(
                transaction: Transaction(
                    id: "2",
                    date: "2024-01-10T10:30:00Z",
                    transactionAmount: "1500.00",
                    transactionType: "rent",
                    description: "Aluguel",
                    isDebit: true
                )
            )
            
            TransactionRowView(
                transaction: Transaction(
                    id: "3",
                    date: "2024-01-05T10:30:00Z",
                    transactionAmount: "350.75",
                    transactionType: "shopping",
                    description: "Supermercado",
                    isDebit: true
                )
            )
            
            TransactionRowView(
                transaction: Transaction(
                    id: "4",
                    date: "2024-01-01T10:30:00Z",
                    transactionAmount: "200.00",
                    transactionType: "transfer",
                    description: nil,
                    isDebit: true
                )
            )
        }
        .listStyle(.plain)
    }
}

// Preview Dark Mode
struct TransactionRowView_DarkMode_Previews: PreviewProvider {
    static var previews: some View {
        List {
            TransactionRowView(
                transaction: Transaction(
                    id: "1",
                    date: "2024-01-15T10:30:00Z",
                    transactionAmount: "5000.00",
                    transactionType: "salary",
                    description: "Salário",
                    isDebit: false
                )
            )
            TransactionRowView(
                transaction: Transaction(
                    id: "2",
                    date: "2024-01-10T10:30:00Z",
                    transactionAmount: "1500.00",
                    transactionType: "rent",
                    description: "Aluguel",
                    isDebit: true
                )
            )
        }
        .listStyle(.plain)
        .preferredColorScheme(.dark)
    }
}
