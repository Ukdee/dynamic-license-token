# Dynamic License Token Smart Contract

A Clarity-based smart contract for managing tokenized licenses with dynamic expiration, renewal, and revocation capabilities on the Stacks blockchain.

## 📋 Overview

This contract implements a flexible licensing system where:
- **Admins** can issue licenses to users with custom pricing
- **Users** can renew their licenses by paying in STX
- **Admins** can revoke licenses at any time
- **Anyone** can validate and check license status

Perfect for SaaS platforms, software licensing, subscription management, and access control systems.

## ✨ Features

- **Tokenized License System**: Each license is uniquely identified and tracked on-chain
- **Expiration Management**: Licenses automatically expire after a configurable duration (~10 hours)
- **Renewal Mechanism**: Users can renew licenses by paying the renewal fee in STX
- **Admin Revocation**: Admins can revoke active licenses instantly
- **License Validation**: Read-only functions to verify license validity
- **Configurable Pricing**: Set minimum price requirements for licenses
- **Block Height Tracking**: Uses Stacks block height for precise expiration timing

## 🔧 Contract Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `LICENSE-DURATION` | 1440 blocks | ~10 hours (at 25s block time) |
| `MIN-PRICE` | 1,000,000 µSTX | Minimum license price (1 STX) |
| `ADMIN` | `tx-sender` | Contract deployer with admin privileges |

## 📊 Data Structure

Each license stores:
```clarity
{
  owner: principal,        ;; License holder's address
  price: uint,            ;; Renewal price in µSTX
  issued-at: uint,        ;; Block height when issued
  expires-at: uint,       ;; Block height when license expires
  active: bool            ;; License active status
}
