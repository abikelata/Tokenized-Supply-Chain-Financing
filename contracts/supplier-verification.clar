;; Supplier Verification Contract
;; This contract validates legitimate vendors in the supply chain

(define-data-var suppliers-count uint u0)

(define-map suppliers
  { supplier-id: (string-ascii 64) }
  {
    name: (string-ascii 256),
    address: (string-ascii 256),
    industry: (string-ascii 64),
    verified: bool,
    verification-date: uint,
    verification-score: uint
  }
)

(define-public (register-supplier (supplier-id (string-ascii 64)) (name (string-ascii 256)) (address (string-ascii 256)) (industry (string-ascii 64)))
  (begin
    (asserts! (not (is-supplier-registered supplier-id)) (err u1))
    (map-set suppliers
      { supplier-id: supplier-id }
      {
        name: name,
        address: address,
        industry: industry,
        verified: false,
        verification-date: u0,
        verification-score: u0
      }
    )
    (var-set suppliers-count (+ (var-get suppliers-count) u1))
    (ok true)
  )
)

(define-public (verify-supplier (supplier-id (string-ascii 64)) (verification-score uint))
  (let ((current-time (unwrap-panic (get-block-info? time (- block-height u1)))))
    (asserts! (is-supplier-registered supplier-id) (err u2))
    (asserts! (>= verification-score u60) (err u3))
    (map-set suppliers
      { supplier-id: supplier-id }
      (merge (unwrap-panic (map-get? suppliers { supplier-id: supplier-id }))
        {
          verified: true,
          verification-date: current-time,
          verification-score: verification-score
        }
      )
    )
    (ok true)
  )
)

(define-read-only (is-supplier-registered (supplier-id (string-ascii 64)))
  (is-some (map-get? suppliers { supplier-id: supplier-id }))
)

(define-read-only (is-supplier-verified (supplier-id (string-ascii 64)))
  (default-to false (get verified (map-get? suppliers { supplier-id: supplier-id })))
)

(define-read-only (get-supplier-details (supplier-id (string-ascii 64)))
  (map-get? suppliers { supplier-id: supplier-id })
)

(define-read-only (get-suppliers-count)
  (var-get suppliers-count)
)
