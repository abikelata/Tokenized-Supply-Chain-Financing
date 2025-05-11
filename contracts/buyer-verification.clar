;; Buyer Verification Contract
;; This contract validates legitimate purchasers in the supply chain

(define-data-var buyers-count uint u0)

(define-map buyers
  { buyer-id: (string-ascii 64) }
  {
    name: (string-ascii 256),
    address: (string-ascii 256),
    industry: (string-ascii 64),
    verified: bool,
    verification-date: uint,
    credit-score: uint
  }
)

(define-public (register-buyer (buyer-id (string-ascii 64)) (name (string-ascii 256)) (address (string-ascii 256)) (industry (string-ascii 64)))
  (begin
    (asserts! (not (is-buyer-registered buyer-id)) (err u1))
    (map-set buyers
      { buyer-id: buyer-id }
      {
        name: name,
        address: address,
        industry: industry,
        verified: false,
        verification-date: u0,
        credit-score: u0
      }
    )
    (var-set buyers-count (+ (var-get buyers-count) u1))
    (ok true)
  )
)

(define-public (verify-buyer (buyer-id (string-ascii 64)) (credit-score uint))
  (let ((current-time (unwrap-panic (get-block-info? time (- block-height u1)))))
    (asserts! (is-buyer-registered buyer-id) (err u2))
    (asserts! (>= credit-score u50) (err u3))
    (map-set buyers
      { buyer-id: buyer-id }
      (merge (unwrap-panic (map-get? buyers { buyer-id: buyer-id }))
        {
          verified: true,
          verification-date: current-time,
          credit-score: credit-score
        }
      )
    )
    (ok true)
  )
)

(define-read-only (is-buyer-registered (buyer-id (string-ascii 64)))
  (is-some (map-get? buyers { buyer-id: buyer-id }))
)

(define-read-only (is-buyer-verified (buyer-id (string-ascii 64)))
  (default-to false (get verified (map-get? buyers { buyer-id: buyer-id })))
)

(define-read-only (get-buyer-details (buyer-id (string-ascii 64)))
  (map-get? buyers { buyer-id: buyer-id })
)

(define-read-only (get-buyers-count)
  (var-get buyers-count)
)
