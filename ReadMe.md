# FiservAssignment - iOS Mobile Banking App

A native iOS mobile banking application that displays user accounts and transaction details, built as part of a technical assignment.

## 📱 Features

### Portfolio Screen (Accounts List)
- Displays all available accounts for the authenticated user
- Each account shows:
  - Account nickname (falls back to account number if nickname is null)
  - Account type (text representation with appropriate icon)
  - Balance (formatted with currency)
- Pull-to-refresh support (Comming Soon)
- Visual indication for favorite accounts (star icon)
- Error handling with retry option

### Account Details Screen
- Detailed view of selected account including:
  - All portfolio screen information
  - Product name
  - Opened date
  - Branch information
  - Beneficiaries list
- Transaction history with pagination support
- Mark account as favorite (syncs with portfolio screen)
- Load more transactions on scroll
- Error handling for pagination failures with retry option

## 🛠 Technical Stack

- **Language:** Swift
- **UI Framework:** SwiftUI
- **Architecture:** MVVM (Model-View-ViewModel)
- **Minimum iOS Version:** iOS 15.0
- **Dependencies:** None (pure SwiftUI + Foundation)
