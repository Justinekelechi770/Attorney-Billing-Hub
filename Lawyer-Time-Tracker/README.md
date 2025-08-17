# Legal Practice Management & Automated Billing System

A comprehensive smart contract built on the Stacks blockchain for managing legal practices, including client relationships, lawyer profiles, case management, time tracking, automated billing, and payment processing with built-in fee structures and retainer management capabilities.

## Overview

This smart contract provides a complete on-chain solution for legal practice management, enabling law firms to manage their operations entirely on the blockchain. All data and transactions are stored on-chain, providing transparency, immutability, and decentralized access control.

## Key Features

### Core Management Systems
- **Client Profile Management**: Register and manage client information with wallet integration
- **Lawyer Profile Management**: Professional profiles with specialization and hourly rates
- **Legal Case Management**: Create and track legal cases with status updates
- **Time Tracking**: Billable and non-billable time entry system
- **Automated Billing**: Generate invoices from time entries
- **Payment Processing**: STX-based payment system with automated fee distribution
- **Retainer Management**: Client-lawyer retainer agreements with balance tracking

### Financial Features
- Platform fee collection (configurable, default 5%)
- Automated payment distribution between lawyers and platform
- Retainer fund management
- Earnings tracking for lawyers
- Invoice status management (pending, paid, overdue, cancelled)

### Access Control
- Contract owner administrative functions
- Lawyer self-management capabilities
- Client payment and retainer management
- Secure wallet-based authentication

## Contract Structure

### Data Models

#### Client Profile
```
{
    full-name: string-ascii 100,
    wallet-address: principal,
    is-active-client: bool,
    registration-block-height: uint,
    stx-balance: uint
}
```

#### Lawyer Profile
```
{
    full-name: string-ascii 100,
    wallet-address: principal,
    current-hourly-rate: uint,
    practice-specialization: string-ascii 50,
    is-active-lawyer: bool,
    registration-block-height: uint,
    earnings-balance: uint
}
```

#### Legal Case
```
{
    assigned-client-id: uint,
    assigned-lawyer-id: uint,
    case-title: string-ascii 200,
    case-description: string-ascii 500,
    current-status: string-ascii 20,
    case-created-block: uint,
    case-last-updated-block: uint,
    total-billed-amount: uint
}
```

#### Time Entry
```
{
    associated-case-id: uint,
    performing-lawyer-id: uint,
    billing-client-id: uint,
    work-description: string-ascii 500,
    time-spent-minutes: uint,
    applied-hourly-rate: uint,
    calculated-amount: uint,
    work-performed-block: uint,
    is-billable-time: bool,
    has-been-invoiced: bool
}
```

#### Invoice
```
{
    invoiced-client-id: uint,
    billing-lawyer-id: uint,
    related-case-id: uint,
    total-invoice-amount: uint,
    amount-paid-to-date: uint,
    payment-status: string-ascii 20,
    invoice-due-date-block: uint,
    invoice-created-block: uint,
    payment-completed-block: optional uint
}
```

## Business Rules and Constraints

### Validation Rules
- **Hourly Rate**: Between $50 and $10,000 USD
- **Time Entries**: 1 minute to 1440 minutes (24 hours) per entry
- **Platform Fee**: Maximum 20%, default 5%
- **Name Length**: 1-100 characters
- **Specialization**: 1-50 characters
- **Case Title**: 1-200 characters
- **Description**: 1-500 characters

### Status Values
- **Case Status**: "active", "closed", "pending"
- **Invoice Status**: "pending", "paid", "overdue", "cancelled"

## Core Functions

### Administrative Functions (Contract Owner Only)
- `register-new-client`: Register new clients in the system
- `register-new-lawyer`: Register new lawyers with specializations
- `create-new-legal-case`: Create cases linking clients and lawyers
- `generate-client-invoice`: Create invoices for billable work
- `update-legal-case-status`: Change case status
- `mark-invoice-as-overdue`: Update overdue invoices
- `update-platform-fee-percentage`: Adjust platform fees
- `deactivate-client-account`: Deactivate client accounts
- `deactivate-lawyer-account`: Deactivate lawyer accounts
- `mark-time-entries-as-invoiced`: Link time entries to invoices
- `update-case-billed-amount`: Update case billing totals
- `cancel-invoice`: Cancel pending invoices
- `emergency-withdraw-contract-balance`: Emergency fund withdrawal

### Lawyer Functions
- `add-billable-time-entry`: Add time entries to cases
- `update-lawyer-hourly-rate`: Update personal hourly rates
- `withdraw-lawyer-earnings`: Withdraw earned fees
- `update-time-entry-description`: Modify time entry descriptions

### Client Functions
- `pay-invoice-with-stx`: Pay outstanding invoices
- `establish-professional-relationship`: Set up retainer agreements
- `add-retainer-funds`: Add funds to existing retainers
- `terminate-professional-relationship`: End retainer agreements

### Mixed Access Functions
- `pay-from-retainer-balance`: Use retainer funds for payments (owner)

## Read-Only Functions

### Data Retrieval
- `get-client-profile`: Retrieve client information
- `get-lawyer-profile`: Retrieve lawyer information
- `get-case-information`: Retrieve case details
- `get-time-entry-details`: Retrieve time entry information
- `get-invoice-details`: Retrieve invoice information
- `get-payment-transaction`: Retrieve payment records
- `get-professional-relationship-details`: Retrieve retainer information

### Status Checks
- `is-client-active`: Check client account status
- `is-lawyer-active`: Check lawyer account status
- `is-invoice-overdue`: Check if invoice is past due
- `get-retainer-balance`: Check remaining retainer funds
- `get-lawyer-total-earnings`: Check lawyer earnings
- `get-time-entry-billing-status`: Check time entry status

### Calculations
- `calculate-billing-amount`: Calculate fees from time and rate
- `get-current-platform-fee-percentage`: Get current platform fee
- `get-contract-statistics`: Get system-wide statistics

## Error Handling

The contract includes comprehensive error handling with specific error codes for different scenarios:

### Authentication & Authorization (100-199)
- `ERR-UNAUTHORIZED-ACCESS` (100): Access denied
- `ERR-INVALID-OWNER-OPERATION` (101): Invalid owner operation

### Entity Management (200-299)
- `ERR-CLIENT-NOT-FOUND` (200): Client doesn't exist
- `ERR-CLIENT-ALREADY-EXISTS` (201): Client already registered
- `ERR-CLIENT-INACTIVE` (202): Client account inactive
- And similar patterns for lawyers and cases

### Billing & Financial (300-399)
- `ERR-INVALID-AMOUNT` (300): Invalid payment amount
- `ERR-INSUFFICIENT-PAYMENT` (302): Payment too low
- `ERR-INVOICE-ALREADY-PAID` (304): Invoice already settled
- And others for financial operations

### Time Tracking (400-499)
- `ERR-TIME-ENTRY-NOT-FOUND` (400): Time entry doesn't exist
- `ERR-TIME-ALREADY-INVOICED` (402): Time entry already billed

### Data Validation (500-599)
- `ERR-INVALID-NAME-LENGTH` (501): Name format invalid
- `ERR-INVALID-PRINCIPAL-ADDRESS` (507): Invalid wallet address

## Payment Flow

1. **Time Tracking**: Lawyers add billable time entries to cases
2. **Invoice Generation**: Contract owner generates invoices from unbilled time
3. **Payment Processing**: Clients pay invoices using STX
4. **Fee Distribution**: Payments automatically split between lawyer and platform
5. **Balance Updates**: Lawyer earnings and payment records updated

## Retainer System

1. **Relationship Setup**: Clients establish relationships with retainer deposits
2. **Fund Management**: Retainer balances tracked and managed on-chain
3. **Payment Processing**: Retainer funds can be used for invoice payments
4. **Refund Handling**: Unused retainer funds returned when relationship ends

## Security Features

- Wallet-based authentication for all participants
- Role-based access control (owner, lawyer, client)
- Input validation for all parameters
- Protection against common smart contract vulnerabilities
- Emergency withdrawal capability for contract owner

## Deployment Considerations

- Contract owner should be a secure, multisig wallet
- Platform fee percentage should be set according to business model
- Initial hourly rate ranges should reflect market conditions
- Consider gas costs for frequent operations like time tracking

## Integration Notes

This contract is designed to be integrated with frontend applications that can:
- Provide user-friendly interfaces for time tracking
- Generate reports from on-chain data
- Handle wallet connections and transaction signing
- Display real-time billing and payment information