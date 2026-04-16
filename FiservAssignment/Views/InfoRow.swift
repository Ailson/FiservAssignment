//
//  InfoRow.swift
//  FiservAssignment
//
//  Created by Ailson Cordeiro Filho on 14/04/26.
//

import SwiftUI

struct InfoRow: View {
    let title: String
    let value: String?
    
    var body: some View {
        if let value = value, !value.isEmpty {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(value)
                    .font(.subheadline)
            }
        }
    }
}

// MARK: - Preview
struct InfoRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            InfoRow(title: "Número da Conta", value: "12345678")
            InfoRow(title: "Produto", value: "Conta Corrente Premium")
            InfoRow(title: "Campo Vazio", value: nil)
        }
        .padding()
    }
}
