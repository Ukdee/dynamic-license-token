;; -----------------------------------------------------------
;; Contract: dynamic-license-token.clar
;; Purpose:  Tokenized licenses with expiration, renewal, and revocation logic
;; Author:   omar
;; -----------------------------------------------------------

(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-LICENSE-NOT-FOUND (err u101))
(define-constant ERR-LICENSE-EXPIRED (err u102))
(define-constant ERR-INSUFFICIENT-FUNDS (err u103))
(define-constant ERR-ALREADY-ACTIVE (err u104))

(define-constant LICENSE-DURATION u1440) ;; ~10 hours (assuming 25s block time)
(define-constant MIN-PRICE u1000000) ;; 1 STX minimum
(define-constant ADMIN tx-sender) ;; contract deployer

;; -----------------------------------------------------------
;; DATA MAPS
;; -----------------------------------------------------------

(define-map licenses
  { id: uint }
  {
    owner: principal,
    price: uint,
    issued-at: uint,
    expires-at: uint,
    active: bool
  }
)

(define-data-var license-counter uint u0)



;; -----------------------------------------------------------
;; FUNCTIONS
;; -----------------------------------------------------------

;; ADMIN: Issue new license to a user
(define-public (issue-license (recipient principal) (price uint))
  (if (< price MIN-PRICE)
      (err u400)
      (let (
            (id (+ (var-get license-counter) u1))
          )
        (begin
          (var-set license-counter id)
          (map-set licenses { id: id } {
            owner: recipient,
            price: price,
            issued-at: burn-block-height,
            expires-at: (+ burn-block-height LICENSE-DURATION),
            active: true
          })
          (ok id)
        )
      )
  )
)

;; USER: Renew license if expired or about to expire
(define-public (renew-license (id uint))
  (let ((license-opt (map-get? licenses { id: id })))
    (match license-opt license
      (let ((price (get price license)))
        (if (< (stx-get-balance tx-sender) price)
            ERR-INSUFFICIENT-FUNDS
            (begin
              (try! (stx-transfer? price tx-sender (as-contract tx-sender)))
              (map-set licenses { id: id } {
                owner: (get owner license),
                price: price,
                issued-at: burn-block-height,
                expires-at: (+ burn-block-height LICENSE-DURATION),
                active: true
              })
              (ok true)
            )
        )
      )
      ERR-LICENSE-NOT-FOUND
    )
  )
)

;; ADMIN: Revoke a license anytime
(define-public (revoke-license (id uint))
  (let ((license-opt (map-get? licenses { id: id })))
    (match license-opt license
      (if (is-eq tx-sender ADMIN)
          (begin
            (map-set licenses { id: id } {
              owner: (get owner license),
              price: (get price license),
              issued-at: (get issued-at license),
              expires-at: (get expires-at license),
              active: false
            })
            (ok true)
          )
          ERR-NOT-AUTHORIZED
      )
      ERR-LICENSE-NOT-FOUND
    )
  )
)

;; READ: Check if license is active
(define-read-only (is-license-valid (id uint))
  (match (map-get? licenses { id: id }) license
    (if (and (get active license) (>= (get expires-at license) burn-block-height))
        (ok true)
        ERR-LICENSE-EXPIRED
    )
    ERR-LICENSE-NOT-FOUND
  )
)

;; READ: View license info
(define-read-only (get-license (id uint))
  (map-get? licenses { id: id })
)
