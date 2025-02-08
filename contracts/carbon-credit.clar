;; Carbon Credit Contract

(define-fungible-token carbon-credit)

(define-map credit-issuances
  { issuance-id: uint }
  {
    recipient: principal,
    amount: uint,
    timestamp: uint,
    reason: (string-utf8 256)
  }
)

(define-data-var issuance-nonce uint u0)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u401))
(define-constant ERR_NOT_FOUND (err u404))

(define-public (issue-credits (recipient principal) (amount uint) (reason (string-utf8 256)))
  (let
    (
      (issuance-id (+ (var-get issuance-nonce) u1))
    )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (try! (ft-mint? carbon-credit amount recipient))
    (map-set credit-issuances
      { issuance-id: issuance-id }
      {
        recipient: recipient,
        amount: amount,
        timestamp: block-height,
        reason: reason
      }
    )
    (var-set issuance-nonce issuance-id)
    (ok issuance-id)
  )
)

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (begin
    (asserts! (is-eq tx-sender sender) ERR_UNAUTHORIZED)
    (try! (ft-transfer? carbon-credit amount sender recipient))
    (match memo to-print (print to-print) 0x)
    (ok true)
  )
)

(define-read-only (get-balance (account principal))
  (ok (ft-get-balance carbon-credit account))
)

(define-read-only (get-total-supply)
  (ok (ft-get-supply carbon-credit))
)

(define-read-only (get-issuance-info (issuance-id uint))
  (map-get? credit-issuances { issuance-id: issuance-id })
)

