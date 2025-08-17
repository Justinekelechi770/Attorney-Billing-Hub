;; Legal Practice Management & Automated Billing System Smart Contract
;; A comprehensive smart contract for managing legal practices including client relationships,
;; lawyer profiles, case management, time tracking, automated billing, and payment processing
;; with built-in fee structures and retainer management capabilities.
;; ALL OPERATIONS ARE FULLY ON-CHAIN

;; Access Control
(define-constant contract-owner tx-sender)

;; Error Constants - Authentication & Authorization
(define-constant ERR-UNAUTHORIZED-ACCESS (err u100))
(define-constant ERR-INVALID-OWNER-OPERATION (err u101))

;; Error Constants - Entity Management
(define-constant ERR-CLIENT-NOT-FOUND (err u200))
(define-constant ERR-CLIENT-ALREADY-EXISTS (err u201))
(define-constant ERR-CLIENT-INACTIVE (err u202))
(define-constant ERR-LAWYER-NOT-FOUND (err u203))
(define-constant ERR-LAWYER-ALREADY-EXISTS (err u204))
(define-constant ERR-LAWYER-INACTIVE (err u205))
(define-constant ERR-CASE-NOT-FOUND (err u206))
(define-constant ERR-CASE-ALREADY-EXISTS (err u207))
(define-constant ERR-CASE-CLOSED (err u208))

;; Error Constants - Billing & Financial
(define-constant ERR-INVALID-AMOUNT (err u300))
(define-constant ERR-INVALID-HOURLY-RATE (err u301))
(define-constant ERR-INSUFFICIENT-PAYMENT (err u302))
(define-constant ERR-INVOICE-NOT-FOUND (err u303))
(define-constant ERR-INVOICE-ALREADY-PAID (err u304))
(define-constant ERR-INVOICE-CANCELLED (err u305))
(define-constant ERR-PAYMENT-OVERDUE (err u306))
(define-constant ERR-INVALID-FEE-PERCENTAGE (err u307))
(define-constant ERR-INVALID-RETAINER-AMOUNT (err u308))
(define-constant ERR-INSUFFICIENT-FUNDS (err u309))

;; Error Constants - Time Tracking
(define-constant ERR-TIME-ENTRY-NOT-FOUND (err u400))
(define-constant ERR-INVALID-TIME-ENTRY (err u401))
(define-constant ERR-TIME-ALREADY-INVOICED (err u402))
(define-constant ERR-INVALID-BILLABLE-STATUS (err u403))

;; Error Constants - Data Validation
(define-constant ERR-INVALID-EMAIL-FORMAT (err u500))
(define-constant ERR-INVALID-NAME-LENGTH (err u501))
(define-constant ERR-INVALID-SPECIALIZATION (err u502))
(define-constant ERR-INVALID-CASE-TITLE (err u503))
(define-constant ERR-INVALID-DESCRIPTION-LENGTH (err u504))
(define-constant ERR-INVALID-STATUS-VALUE (err u505))
(define-constant ERR-INVALID-DUE-DATE (err u506))
(define-constant ERR-INVALID-PRINCIPAL-ADDRESS (err u507))
(define-constant ERR-MISSING-REQUIRED-FIELD (err u508))

;; Business Logic Constants
(define-constant minimum-hourly-rate-usd u50)
(define-constant maximum-hourly-rate-usd u10000)
(define-constant minimum-billable-minutes u1)
(define-constant maximum-daily-minutes u1440)
(define-constant default-platform-fee-percentage u5)
(define-constant maximum-platform-fee-percentage u20)
(define-constant minutes-per-hour u60)
(define-constant percentage-calculation-basis u100)
(define-constant decimal-precision-multiplier u100)
(define-constant hour-to-minute-converter u6000)

;; State Variables
(define-data-var next-available-client-id uint u1)
(define-data-var next-available-lawyer-id uint u1)
(define-data-var next-available-time-entry-id uint u1)
(define-data-var next-available-invoice-id uint u1)
(define-data-var next-available-case-id uint u1)
(define-data-var next-available-payment-id uint u1)
(define-data-var current-platform-fee-percentage uint default-platform-fee-percentage)

;; Client Profile Management
(define-map client-profiles 
    uint 
    {
        full-name: (string-ascii 100),
        wallet-address: principal,
        is-active-client: bool,
        registration-block-height: uint,
        stx-balance: uint
    }
)

;; Legal Professional Profiles
(define-map lawyer-profiles 
    uint 
    {
        full-name: (string-ascii 100),
        wallet-address: principal,
        current-hourly-rate: uint,
        practice-specialization: (string-ascii 50),
        is-active-lawyer: bool,
        registration-block-height: uint,
        earnings-balance: uint
    }
)

;; Legal Case Management
(define-map legal-cases
    uint
    {
        assigned-client-id: uint,
        assigned-lawyer-id: uint,
        case-title: (string-ascii 200),
        case-description: (string-ascii 500),
        current-status: (string-ascii 20),
        case-created-block: uint,
        case-last-updated-block: uint,
        total-billed-amount: uint
    }
)

;; Time Entry & Billing Records
(define-map billable-time-entries 
    uint 
    {
        associated-case-id: uint,
        performing-lawyer-id: uint,
        billing-client-id: uint,
        work-description: (string-ascii 500),
        time-spent-minutes: uint,
        applied-hourly-rate: uint,
        calculated-amount: uint,
        work-performed-block: uint,
        is-billable-time: bool,
        has-been-invoiced: bool
    }
)

;; Invoice Management System
(define-map client-invoices 
    uint 
    {
        invoiced-client-id: uint,
        billing-lawyer-id: uint,
        related-case-id: uint,
        total-invoice-amount: uint,
        amount-paid-to-date: uint,
        payment-status: (string-ascii 20),
        invoice-due-date-block: uint,
        invoice-created-block: uint,
        payment-completed-block: (optional uint)
    }
)

;; Payment Transaction Records
(define-map payment-transactions
    uint
    {
        target-invoice-id: uint,
        paying-client-id: uint,
        receiving-lawyer-id: uint,
        payment-amount: uint,
        platform-fee-amount: uint,
        lawyer-net-amount: uint,
        transaction-date-block: uint
    }
)

;; Client-Lawyer Professional Relationships
(define-map professional-relationships
    { client-reference-id: uint, lawyer-reference-id: uint }
    {
        retainer-fee-amount: uint,
        retainer-balance: uint,
        relationship-is-active: bool,
        relationship-established-block: uint
    }
)

;; Retrieve complete client information
(define-read-only (get-client-profile (target-client-id uint))
    (map-get? client-profiles target-client-id)
)

;; Retrieve complete lawyer information
(define-read-only (get-lawyer-profile (target-lawyer-id uint))
    (map-get? lawyer-profiles target-lawyer-id)
)

;; Retrieve legal case details
(define-read-only (get-case-information (target-case-id uint))
    (map-get? legal-cases target-case-id)
)

;; Retrieve specific time entry
(define-read-only (get-time-entry-details (entry-reference-id uint))
    (map-get? billable-time-entries entry-reference-id)
)

;; Retrieve invoice information
(define-read-only (get-invoice-details (target-invoice-id uint))
    (map-get? client-invoices target-invoice-id)
)

;; Get current platform fee percentage
(define-read-only (get-current-platform-fee-percentage)
    (var-get current-platform-fee-percentage)
)

;; Calculate billing amount from time and rate
(define-read-only (calculate-billing-amount (minutes-worked uint) (hourly-billing-rate uint))
    (let ((hours-in-decimal-format (* minutes-worked decimal-precision-multiplier)))
        (/ (* hours-in-decimal-format hourly-billing-rate) hour-to-minute-converter)
    )
)

;; Get professional relationship details
(define-read-only (get-professional-relationship-details (client-reference-id uint) (lawyer-reference-id uint))
    (map-get? professional-relationships { 
        client-reference-id: client-reference-id, 
        lawyer-reference-id: lawyer-reference-id 
    })
)

;; Check if client is active and exists
(define-read-only (is-client-active (client-reference-id uint))
    (match (get-client-profile client-reference-id)
        client-data (get is-active-client client-data)
        false
    )
)

;; Check if lawyer is active and exists
(define-read-only (is-lawyer-active (lawyer-reference-id uint))
    (match (get-lawyer-profile lawyer-reference-id)
        lawyer-data (get is-active-lawyer lawyer-data)
        false
    )
)

;; Get payment transaction details
(define-read-only (get-payment-transaction (payment-id uint))
    (map-get? payment-transactions payment-id)
)

;; Get contract statistics
(define-read-only (get-contract-statistics)
    {
        total-clients: (- (var-get next-available-client-id) u1),
        total-lawyers: (- (var-get next-available-lawyer-id) u1),
        total-cases: (- (var-get next-available-case-id) u1),
        total-invoices: (- (var-get next-available-invoice-id) u1),
        total-time-entries: (- (var-get next-available-time-entry-id) u1),
        total-payments: (- (var-get next-available-payment-id) u1),
        current-platform-fee: (var-get current-platform-fee-percentage)
    }
)

;; Check if invoice is overdue
(define-read-only (is-invoice-overdue (invoice-reference-id uint))
    (match (get-invoice-details invoice-reference-id)
        invoice-data (and 
                        (is-eq (get payment-status invoice-data) "pending")
                        (< (get invoice-due-date-block invoice-data) block-height))
        false
    )
)

;; Calculate remaining retainer balance
(define-read-only (get-retainer-balance (client-reference-id uint) (lawyer-reference-id uint))
    (match (get-professional-relationship-details client-reference-id lawyer-reference-id)
        relationship-data (get retainer-balance relationship-data)
        u0
    )
)

;; Get lawyer's total earnings on platform
(define-read-only (get-lawyer-total-earnings (lawyer-reference-id uint))
    (match (get-lawyer-profile lawyer-reference-id)
        lawyer-data (get earnings-balance lawyer-data)
        u0
    )
)

;; Get time entry billing status
(define-read-only (get-time-entry-billing-status (time-entry-id uint))
    (match (get-time-entry-details time-entry-id)
        time-data {
            is-billable: (get is-billable-time time-data),
            has-been-invoiced: (get has-been-invoiced time-data),
            calculated-amount: (get calculated-amount time-data)
        }
        {
            is-billable: false,
            has-been-invoiced: false,
            calculated-amount: u0
        }
    )
)

;; Validate hourly rate within business rules
(define-private (is-hourly-rate-valid (proposed-rate uint))
    (and (>= proposed-rate minimum-hourly-rate-usd) 
         (<= proposed-rate maximum-hourly-rate-usd))
)

;; Validate time entry duration
(define-private (is-time-duration-valid (minutes-to-validate uint))
    (and (>= minutes-to-validate minimum-billable-minutes) 
         (<= minutes-to-validate maximum-daily-minutes))
)

;; Validate name length and format
(define-private (is-name-format-valid (name-to-check (string-ascii 100)))
    (and (> (len name-to-check) u1) 
         (< (len name-to-check) u100))
)

;; Validate specialization field
(define-private (is-specialization-valid (specialization-to-check (string-ascii 50)))
    (and (> (len specialization-to-check) u1) 
         (< (len specialization-to-check) u50))
)

;; Validate case title
(define-private (is-case-title-valid (title-to-check (string-ascii 200)))
    (and (> (len title-to-check) u1) 
         (< (len title-to-check) u200))
)

;; Validate description length
(define-private (is-description-valid (description-to-check (string-ascii 500)))
    (and (> (len description-to-check) u1) 
         (< (len description-to-check) u500))
)

;; Validate principal address
(define-private (is-principal-address-valid (address-to-check principal))
    (not (is-eq address-to-check 'SP000000000000000000002Q6VF78))
)

;; Check if caller is contract owner
(define-private (is-caller-contract-owner)
    (is-eq tx-sender contract-owner)
)

;; Validate case status values
(define-private (is-case-status-valid (status-to-check (string-ascii 20)))
    (or (is-eq status-to-check "active") 
        (or (is-eq status-to-check "closed") 
            (is-eq status-to-check "pending")))
)

;; Validate invoice status values  
(define-private (is-invoice-status-valid (status-to-check (string-ascii 20)))
    (or (is-eq status-to-check "pending") 
        (or (is-eq status-to-check "paid") 
            (or (is-eq status-to-check "overdue") 
                (is-eq status-to-check "cancelled"))))
)

;; Validate ID ranges against current state
(define-private (is-case-id-in-valid-range (case-reference-id uint))
    (and (>= case-reference-id u1) 
         (< case-reference-id (var-get next-available-case-id)))
)

(define-private (is-client-id-in-valid-range (client-reference-id uint))
    (and (>= client-reference-id u1) 
         (< client-reference-id (var-get next-available-client-id)))
)

(define-private (is-lawyer-id-in-valid-range (lawyer-reference-id uint))
    (and (>= lawyer-reference-id u1) 
         (< lawyer-reference-id (var-get next-available-lawyer-id)))
)

;; Register new client in the system
(define-public (register-new-client 
    (client-full-name (string-ascii 100)) 
    (client-wallet-address principal))
    (let ((new-client-id (var-get next-available-client-id)))
        (asserts! (is-caller-contract-owner) ERR-UNAUTHORIZED-ACCESS)
        (asserts! (is-name-format-valid client-full-name) ERR-INVALID-NAME-LENGTH)
        (asserts! (is-principal-address-valid client-wallet-address) ERR-INVALID-PRINCIPAL-ADDRESS)
        (asserts! (is-none (map-get? client-profiles new-client-id)) ERR-CLIENT-ALREADY-EXISTS)
        
        (map-set client-profiles new-client-id {
            full-name: client-full-name,
            wallet-address: client-wallet-address,
            is-active-client: true,
            registration-block-height: block-height,
            stx-balance: u0
        })
        
        (var-set next-available-client-id (+ new-client-id u1))
        (ok new-client-id)
    )
)

;; Register new lawyer in the system
(define-public (register-new-lawyer 
    (lawyer-full-name (string-ascii 100)) 
    (lawyer-wallet-address principal) 
    (initial-hourly-rate uint) 
    (lawyer-specialization (string-ascii 50)))
    (let ((new-lawyer-id (var-get next-available-lawyer-id)))
        (asserts! (is-caller-contract-owner) ERR-UNAUTHORIZED-ACCESS)
        (asserts! (is-name-format-valid lawyer-full-name) ERR-INVALID-NAME-LENGTH)
        (asserts! (is-principal-address-valid lawyer-wallet-address) ERR-INVALID-PRINCIPAL-ADDRESS)
        (asserts! (is-specialization-valid lawyer-specialization) ERR-INVALID-SPECIALIZATION)
        (asserts! (is-hourly-rate-valid initial-hourly-rate) ERR-INVALID-HOURLY-RATE)
        (asserts! (is-none (map-get? lawyer-profiles new-lawyer-id)) ERR-LAWYER-ALREADY-EXISTS)
        
        (map-set lawyer-profiles new-lawyer-id {
            full-name: lawyer-full-name,
            wallet-address: lawyer-wallet-address,
            current-hourly-rate: initial-hourly-rate,
            practice-specialization: lawyer-specialization,
            is-active-lawyer: true,
            registration-block-height: block-height,
            earnings-balance: u0
        })
        
        (var-set next-available-lawyer-id (+ new-lawyer-id u1))
        (ok new-lawyer-id)
    )
)

;; Create new legal case
(define-public (create-new-legal-case 
    (client-reference-id uint) 
    (lawyer-reference-id uint) 
    (case-title (string-ascii 200)) 
    (case-description (string-ascii 500)))
    (let ((new-case-id (var-get next-available-case-id)))
        (asserts! (is-caller-contract-owner) ERR-UNAUTHORIZED-ACCESS)
        (asserts! (is-some (get-client-profile client-reference-id)) ERR-CLIENT-NOT-FOUND)
        (asserts! (is-some (get-lawyer-profile lawyer-reference-id)) ERR-LAWYER-NOT-FOUND)
        (asserts! (is-client-active client-reference-id) ERR-CLIENT-INACTIVE)
        (asserts! (is-lawyer-active lawyer-reference-id) ERR-LAWYER-INACTIVE)
        (asserts! (is-case-title-valid case-title) ERR-INVALID-CASE-TITLE)
        (asserts! (is-description-valid case-description) ERR-INVALID-DESCRIPTION-LENGTH)
        
        (map-set legal-cases new-case-id {
            assigned-client-id: client-reference-id,
            assigned-lawyer-id: lawyer-reference-id,
            case-title: case-title,
            case-description: case-description,
            current-status: "active",
            case-created-block: block-height,
            case-last-updated-block: block-height,
            total-billed-amount: u0
        })
        
        (var-set next-available-case-id (+ new-case-id u1))
        (ok new-case-id)
    )
)

;; Add billable time entry to case
(define-public (add-billable-time-entry 
    (case-reference-id uint) 
    (lawyer-reference-id uint) 
    (work-description (string-ascii 500)) 
    (minutes-worked uint) 
    (is-billable-work bool))
    (let ((new-entry-id (var-get next-available-time-entry-id))
          (case-information (unwrap! (get-case-information case-reference-id) ERR-CASE-NOT-FOUND))
          (lawyer-information (unwrap! (get-lawyer-profile lawyer-reference-id) ERR-LAWYER-NOT-FOUND))
          (client-reference-id (get assigned-client-id case-information))
          (current-hourly-rate (get current-hourly-rate lawyer-information))
          (calculated-billing-amount (calculate-billing-amount minutes-worked current-hourly-rate)))
        
        (asserts! (or (is-caller-contract-owner) 
                      (is-eq tx-sender (get wallet-address lawyer-information))) 
                  ERR-UNAUTHORIZED-ACCESS)
        (asserts! (is-time-duration-valid minutes-worked) ERR-INVALID-TIME-ENTRY)
        (asserts! (is-description-valid work-description) ERR-INVALID-DESCRIPTION-LENGTH)
        (asserts! (is-eq (get assigned-lawyer-id case-information) lawyer-reference-id) ERR-UNAUTHORIZED-ACCESS)
        (asserts! (not (is-eq (get current-status case-information) "closed")) ERR-CASE-CLOSED)
        
        (map-set billable-time-entries new-entry-id {
            associated-case-id: case-reference-id,
            performing-lawyer-id: lawyer-reference-id,
            billing-client-id: client-reference-id,
            work-description: work-description,
            time-spent-minutes: minutes-worked,
            applied-hourly-rate: current-hourly-rate,
            calculated-amount: calculated-billing-amount,
            work-performed-block: block-height,
            is-billable-time: is-billable-work,
            has-been-invoiced: false
        })
        
        (var-set next-available-time-entry-id (+ new-entry-id u1))
        (ok new-entry-id)
    )
)

;; Generate invoice for unbilled time entries
(define-public (generate-client-invoice 
    (client-reference-id uint) 
    (lawyer-reference-id uint) 
    (case-reference-id uint) 
    (total-amount uint)
    (due-date-in-blocks uint))
    (let ((new-invoice-id (var-get next-available-invoice-id))
          (invoice-due-date (+ block-height due-date-in-blocks)))
        (asserts! (is-caller-contract-owner) ERR-UNAUTHORIZED-ACCESS)
        (asserts! (is-some (get-client-profile client-reference-id)) ERR-CLIENT-NOT-FOUND)
        (asserts! (is-some (get-lawyer-profile lawyer-reference-id)) ERR-LAWYER-NOT-FOUND)
        (asserts! (is-some (get-case-information case-reference-id)) ERR-CASE-NOT-FOUND)
        (asserts! (> due-date-in-blocks u0) ERR-INVALID-DUE-DATE)
        (asserts! (> total-amount u0) ERR-INVALID-AMOUNT)
        
        (map-set client-invoices new-invoice-id {
            invoiced-client-id: client-reference-id,
            billing-lawyer-id: lawyer-reference-id,
            related-case-id: case-reference-id,
            total-invoice-amount: total-amount,
            amount-paid-to-date: u0,
            payment-status: "pending",
            invoice-due-date-block: invoice-due-date,
            invoice-created-block: block-height,
            payment-completed-block: none
        })
        
        (var-set next-available-invoice-id (+ new-invoice-id u1))
        (ok new-invoice-id)
    )
)

;; Process STX payment for outstanding invoice
(define-public (pay-invoice-with-stx (invoice-reference-id uint) (payment-amount uint))
    (let ((invoice-information (unwrap! (get-invoice-details invoice-reference-id) ERR-INVOICE-NOT-FOUND))
          (client-information (unwrap! (get-client-profile (get invoiced-client-id invoice-information)) 
                                        ERR-CLIENT-NOT-FOUND))
          (lawyer-information (unwrap! (get-lawyer-profile (get billing-lawyer-id invoice-information))
                                       ERR-LAWYER-NOT-FOUND))
          (total-amount-due (get total-invoice-amount invoice-information))
          (platform-fee-amount (/ (* total-amount-due (var-get current-platform-fee-percentage)) 
                                   percentage-calculation-basis))
          (lawyer-payment-amount (- total-amount-due platform-fee-amount))
          (new-payment-id (var-get next-available-payment-id)))
        
        (asserts! (is-eq tx-sender (get wallet-address client-information)) ERR-UNAUTHORIZED-ACCESS)
        (asserts! (is-eq (get payment-status invoice-information) "pending") ERR-INVOICE-ALREADY-PAID)
        (asserts! (>= payment-amount total-amount-due) ERR-INSUFFICIENT-PAYMENT)
        
        (try! (stx-transfer? lawyer-payment-amount tx-sender (get wallet-address lawyer-information)))
        (try! (stx-transfer? platform-fee-amount tx-sender contract-owner))
        
        (map-set payment-transactions new-payment-id {
            target-invoice-id: invoice-reference-id,
            paying-client-id: (get invoiced-client-id invoice-information),
            receiving-lawyer-id: (get billing-lawyer-id invoice-information),
            payment-amount: total-amount-due,
            platform-fee-amount: platform-fee-amount,
            lawyer-net-amount: lawyer-payment-amount,
            transaction-date-block: block-height
        })
        
        (map-set client-invoices invoice-reference-id (merge invoice-information {
            amount-paid-to-date: total-amount-due,
            payment-status: "paid",
            payment-completed-block: (some block-height)
        }))
        
        (map-set lawyer-profiles (get billing-lawyer-id invoice-information) 
                 (merge lawyer-information { 
                     earnings-balance: (+ (get earnings-balance lawyer-information) lawyer-payment-amount)
                 }))
        
        (var-set next-available-payment-id (+ new-payment-id u1))
        (ok true)
    )
)

;; Establish professional client-lawyer relationship with retainer
(define-public (establish-professional-relationship 
    (client-reference-id uint) 
    (lawyer-reference-id uint) 
    (retainer-fee-amount uint))
    (let ((client-info (unwrap! (get-client-profile client-reference-id) ERR-CLIENT-NOT-FOUND))
          (lawyer-info (unwrap! (get-lawyer-profile lawyer-reference-id) ERR-LAWYER-NOT-FOUND)))
        (asserts! (is-eq tx-sender (get wallet-address client-info)) ERR-UNAUTHORIZED-ACCESS)
        (asserts! (is-client-active client-reference-id) ERR-CLIENT-INACTIVE)
        (asserts! (is-lawyer-active lawyer-reference-id) ERR-LAWYER-INACTIVE)
        (asserts! (> retainer-fee-amount u0) ERR-INVALID-RETAINER-AMOUNT)
        
        (try! (stx-transfer? retainer-fee-amount tx-sender (as-contract tx-sender)))
        
        (map-set professional-relationships 
            { client-reference-id: client-reference-id, lawyer-reference-id: lawyer-reference-id }
            {
                retainer-fee-amount: retainer-fee-amount,
                retainer-balance: retainer-fee-amount,
                relationship-is-active: true,
                relationship-established-block: block-height
            }
        )
        (ok true)
    )
)

;; Use retainer balance for payment
(define-public (pay-from-retainer-balance 
    (client-reference-id uint) 
    (lawyer-reference-id uint) 
    (payment-amount uint))
    (let ((relationship-data (unwrap! (get-professional-relationship-details client-reference-id lawyer-reference-id) 
                                      ERR-CLIENT-NOT-FOUND))
          (current-balance (get retainer-balance relationship-data)))
        (asserts! (is-caller-contract-owner) ERR-UNAUTHORIZED-ACCESS)
        (asserts! (>= current-balance payment-amount) ERR-INSUFFICIENT-FUNDS)
        (asserts! (get relationship-is-active relationship-data) ERR-CLIENT-INACTIVE)
        
        (try! (as-contract (stx-transfer? payment-amount tx-sender 
                                         (get wallet-address (unwrap! (get-lawyer-profile lawyer-reference-id) 
                                                                      ERR-LAWYER-NOT-FOUND)))))
        
        (map-set professional-relationships 
            { client-reference-id: client-reference-id, lawyer-reference-id: lawyer-reference-id }
            (merge relationship-data { 
                retainer-balance: (- current-balance payment-amount)
            }))
        (ok true)
    )
)

;; Update legal case status
(define-public (update-legal-case-status (case-reference-id uint) (new-status-value (string-ascii 20)))
    (let ((case-information (unwrap! (get-case-information case-reference-id) ERR-CASE-NOT-FOUND)))
        (asserts! (is-caller-contract-owner) ERR-UNAUTHORIZED-ACCESS)
        (asserts! (is-case-status-valid new-status-value) ERR-INVALID-STATUS-VALUE)
        
        (map-set legal-cases case-reference-id 
                 (merge case-information { 
                     current-status: new-status-value,
                     case-last-updated-block: block-height 
                 }))
        (ok true)
    )
)

;; Update lawyer's hourly billing rate
(define-public (update-lawyer-hourly-rate (lawyer-reference-id uint) (new-hourly-rate uint))
    (let ((lawyer-information (unwrap! (get-lawyer-profile lawyer-reference-id) ERR-LAWYER-NOT-FOUND)))
        (asserts! (or (is-caller-contract-owner) 
                      (is-eq tx-sender (get wallet-address lawyer-information))) 
                  ERR-UNAUTHORIZED-ACCESS)
        (asserts! (is-hourly-rate-valid new-hourly-rate) ERR-INVALID-HOURLY-RATE)
        
        (map-set lawyer-profiles lawyer-reference-id 
                 (merge lawyer-information { current-hourly-rate: new-hourly-rate }))
        (ok true)
    )
)

;; Mark invoice as overdue when payment deadline passed
(define-public (mark-invoice-as-overdue (invoice-reference-id uint))
    (let ((invoice-information (unwrap! (get-invoice-details invoice-reference-id) ERR-INVOICE-NOT-FOUND)))
        (asserts! (is-caller-contract-owner) ERR-UNAUTHORIZED-ACCESS)
        (asserts! (is-eq (get payment-status invoice-information) "pending") ERR-INVALID-STATUS-VALUE)
        (asserts! (< (get invoice-due-date-block invoice-information) block-height) ERR-INVALID-DUE-DATE)
        
        (map-set client-invoices invoice-reference-id 
                 (merge invoice-information { payment-status: "overdue" }))
        (ok true)
    )
)

;; Update platform fee percentage (owner only)
(define-public (update-platform-fee-percentage (new-fee-percentage uint))
    (begin
        (asserts! (is-caller-contract-owner) ERR-UNAUTHORIZED-ACCESS)
        (asserts! (<= new-fee-percentage maximum-platform-fee-percentage) ERR-INVALID-FEE-PERCENTAGE)
        (asserts! (>= new-fee-percentage u0) ERR-INVALID-FEE-PERCENTAGE)
        
        (var-set current-platform-fee-percentage new-fee-percentage)
        (ok true)
    )
)

;; Withdraw lawyer earnings
(define-public (withdraw-lawyer-earnings (lawyer-reference-id uint) (withdrawal-amount uint))
    (let ((lawyer-information (unwrap! (get-lawyer-profile lawyer-reference-id) ERR-LAWYER-NOT-FOUND))
          (current-earnings (get earnings-balance lawyer-information)))
        (asserts! (is-eq tx-sender (get wallet-address lawyer-information)) ERR-UNAUTHORIZED-ACCESS)
        (asserts! (>= current-earnings withdrawal-amount) ERR-INSUFFICIENT-FUNDS)
        (asserts! (> withdrawal-amount u0) ERR-INVALID-AMOUNT)
        
        (try! (as-contract (stx-transfer? withdrawal-amount tx-sender (get wallet-address lawyer-information))))
        
        (map-set lawyer-profiles lawyer-reference-id 
                 (merge lawyer-information { 
                     earnings-balance: (- current-earnings withdrawal-amount)
                 }))
        (ok true)
    )
)

;; Deactivate client account
(define-public (deactivate-client-account (client-reference-id uint))
    (let ((client-information (unwrap! (get-client-profile client-reference-id) ERR-CLIENT-NOT-FOUND)))
        (asserts! (is-caller-contract-owner) ERR-UNAUTHORIZED-ACCESS)
        (asserts! (is-client-id-in-valid-range client-reference-id) ERR-CLIENT-NOT-FOUND)
        
        (map-set client-profiles client-reference-id 
                 (merge client-information { is-active-client: false }))
        (ok true)
    )
)

;; Deactivate lawyer account
(define-public (deactivate-lawyer-account (lawyer-reference-id uint))
    (let ((lawyer-information (unwrap! (get-lawyer-profile lawyer-reference-id) ERR-LAWYER-NOT-FOUND)))
        (asserts! (is-caller-contract-owner) ERR-UNAUTHORIZED-ACCESS)
        (asserts! (is-lawyer-id-in-valid-range lawyer-reference-id) ERR-LAWYER-NOT-FOUND)
        
        (map-set lawyer-profiles lawyer-reference-id 
                 (merge lawyer-information { is-active-lawyer: false }))
        (ok true)
    )
)

;; Mark time entries as invoiced
(define-public (mark-time-entries-as-invoiced (time-entry-ids (list 50 uint)) (invoice-reference-id uint))
    (let ((invoice-info (unwrap! (get-invoice-details invoice-reference-id) ERR-INVOICE-NOT-FOUND)))
        (asserts! (is-caller-contract-owner) ERR-UNAUTHORIZED-ACCESS)
        (asserts! (is-eq (get payment-status invoice-info) "pending") ERR-INVOICE-ALREADY-PAID)
        
        (fold mark-single-time-entry-as-invoiced time-entry-ids (ok true))
    )
)

;; Helper function for marking individual time entries
(define-private (mark-single-time-entry-as-invoiced (time-entry-id uint) (previous-result (response bool uint)))
    (match previous-result
        success (match (get-time-entry-details time-entry-id)
                    time-entry-data (if (get has-been-invoiced time-entry-data)
                                        ERR-TIME-ALREADY-INVOICED
                                        (begin
                                            (map-set billable-time-entries time-entry-id 
                                                     (merge time-entry-data { has-been-invoiced: true }))
                                            (ok true)
                                        ))
                    ERR-TIME-ENTRY-NOT-FOUND
                )
        error-code previous-result
    )
)

;; Add retainer funds to existing relationship
(define-public (add-retainer-funds 
    (client-reference-id uint) 
    (lawyer-reference-id uint) 
    (additional-amount uint))
    (let ((client-info (unwrap! (get-client-profile client-reference-id) ERR-CLIENT-NOT-FOUND))
          (relationship-data (unwrap! (get-professional-relationship-details client-reference-id lawyer-reference-id) 
                                      ERR-CLIENT-NOT-FOUND))
          (current-balance (get retainer-balance relationship-data)))
        (asserts! (is-eq tx-sender (get wallet-address client-info)) ERR-UNAUTHORIZED-ACCESS)
        (asserts! (> additional-amount u0) ERR-INVALID-AMOUNT)
        (asserts! (get relationship-is-active relationship-data) ERR-CLIENT-INACTIVE)
        
        (try! (stx-transfer? additional-amount tx-sender (as-contract tx-sender)))
        
        (map-set professional-relationships 
            { client-reference-id: client-reference-id, lawyer-reference-id: lawyer-reference-id }
            (merge relationship-data { 
                retainer-balance: (+ current-balance additional-amount)
            }))
        (ok true)
    )
)

;; Update case total billed amount
(define-public (update-case-billed-amount (case-reference-id uint) (additional-amount uint))
    (let ((case-information (unwrap! (get-case-information case-reference-id) ERR-CASE-NOT-FOUND))
          (current-total (get total-billed-amount case-information)))
        (asserts! (is-caller-contract-owner) ERR-UNAUTHORIZED-ACCESS)
        (asserts! (> additional-amount u0) ERR-INVALID-AMOUNT)
        
        (map-set legal-cases case-reference-id 
                 (merge case-information { 
                     total-billed-amount: (+ current-total additional-amount),
                     case-last-updated-block: block-height
                 }))
        (ok true)
    )
)

;; Cancel invoice
(define-public (cancel-invoice (invoice-reference-id uint))
    (let ((invoice-information (unwrap! (get-invoice-details invoice-reference-id) ERR-INVOICE-NOT-FOUND)))
        (asserts! (is-caller-contract-owner) ERR-UNAUTHORIZED-ACCESS)
        (asserts! (is-eq (get payment-status invoice-information) "pending") ERR-INVOICE-ALREADY-PAID)
        
        (map-set client-invoices invoice-reference-id 
                 (merge invoice-information { payment-status: "cancelled" }))
        (ok true)
    )
)

;; Terminate professional relationship
(define-public (terminate-professional-relationship 
    (client-reference-id uint) 
    (lawyer-reference-id uint))
    (let ((relationship-data (unwrap! (get-professional-relationship-details client-reference-id lawyer-reference-id) 
                                      ERR-CLIENT-NOT-FOUND))
          (remaining-balance (get retainer-balance relationship-data))
          (client-info (unwrap! (get-client-profile client-reference-id) ERR-CLIENT-NOT-FOUND)))
        (asserts! (or (is-caller-contract-owner)
                      (is-eq tx-sender (get wallet-address client-info))) ERR-UNAUTHORIZED-ACCESS)
        (asserts! (get relationship-is-active relationship-data) ERR-CLIENT-INACTIVE)
        
        (if (> remaining-balance u0)
            (try! (as-contract (stx-transfer? remaining-balance tx-sender (get wallet-address client-info))))
            true
        )
        
        (map-set professional-relationships 
            { client-reference-id: client-reference-id, lawyer-reference-id: lawyer-reference-id }
            (merge relationship-data { 
                relationship-is-active: false,
                retainer-balance: u0
            }))
        (ok true)
    )
)

;; Bulk update time entry descriptions
(define-public (update-time-entry-description (time-entry-id uint) (new-description (string-ascii 500)))
    (let ((time-entry-data (unwrap! (get-time-entry-details time-entry-id) ERR-TIME-ENTRY-NOT-FOUND))
          (lawyer-info (unwrap! (get-lawyer-profile (get performing-lawyer-id time-entry-data)) ERR-LAWYER-NOT-FOUND)))
        (asserts! (or (is-caller-contract-owner)
                      (is-eq tx-sender (get wallet-address lawyer-info))) ERR-UNAUTHORIZED-ACCESS)
        (asserts! (not (get has-been-invoiced time-entry-data)) ERR-TIME-ALREADY-INVOICED)
        (asserts! (is-description-valid new-description) ERR-INVALID-DESCRIPTION-LENGTH)
        
        (map-set billable-time-entries time-entry-id 
                 (merge time-entry-data { work-description: new-description }))
        (ok true)
    )
)

;; Emergency contract functions
(define-public (emergency-withdraw-contract-balance (recipient principal))
    (begin
        (asserts! (is-caller-contract-owner) ERR-UNAUTHORIZED-ACCESS)
        (try! (as-contract (stx-transfer? (stx-get-balance tx-sender) tx-sender recipient)))
        (ok true)
    )
)