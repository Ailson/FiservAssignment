//
//  TransactionListView.swift
//  FiservAssignment
//
//  Created by Ailson Cordeiro Filho on 14/04/26.
//
import SwiftUI

struct TransactionsListView: View {
    let transactions: [Transaction]
    let onLoadMore: () -> Void
    let isLoadingMore: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Transaction History")
                    .font(.headline)
                Spacer()
                if !transactions.isEmpty {
                    Text("\(transactions.count) transactions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            if transactions.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary)
                    Text("No transactions found")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(Array(transactions.enumerated()), id: \.element.id) { index, transaction in
                        TransactionRowView(transaction: transaction)
                            .onAppear {
                                if index == transactions.count - 3 {
                                    onLoadMore()
                                }
                            }
                        
                        if index < transactions.count - 1 {
                            Divider()
                                .padding(.leading)
                        }
                    }
                    
                    if isLoadingMore {
                        HStack {
                            Spacer()
                            ProgressView()
                                .padding()
                            Spacer()
                        }
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            }
        }
        .padding(.horizontal)
    }
}
// MARK: - Preview
struct TransactionsListView_Previews: PreviewProvider {
    static var previews: some View {
        let mockTransactions = [
            Transaction(
                id: "1",
                date: "2024-01-15T14:30:00Z",
                transactionAmount: "150.00",
                transactionType: "bill",
                description: "Pagamento de conta",
                isDebit: true
            ),
            Transaction(
                id: "2",
                date: "2024-01-14T09:15:00Z",
                transactionAmount: "1000.00",
                transactionType: "deposit",
                description: "Depósito",
                isDebit: false
            ),
            Transaction(
                id: "3",
                date: "2024-01-13T16:45:00Z",
                transactionAmount: "500.00",
                transactionType: "transfer",
                description: "Transferência recebida",
                isDebit: false
            ),
            Transaction(
                id: "4",
                date: "2024-01-12T11:20:00Z",
                transactionAmount: "299.90",
                transactionType: "shopping",
                description: "Compra online",
                isDebit: true
            )
        ]
        
        ScrollView {
            TransactionsListView(
                transactions: mockTransactions,
                onLoadMore: {},
                isLoadingMore: false
            )
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground))
    }
}
