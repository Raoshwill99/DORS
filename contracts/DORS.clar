;; Decentralized Oracle Redundancy System - Initial Implementation
;; Contract to manage oracle nodes and their data submissions

(define-constant contract-owner tx-sender)
(define-constant min-stake u1000000) ;; Minimum stake required to become an oracle node
(define-constant consensus-threshold u80) ;; 80% consensus required

;; Data structures
(define-map oracle-nodes 
    principal 
    {
        stake: uint,
        active: bool,
        accuracy-score: uint,
        total-submissions: uint
    }
)

(define-map price-submissions
    uint  ;; submission-id
    {
        oracle: principal,
        price: uint,
        timestamp: uint,
        verified: bool
    }
)

;; Counter for submission IDs
(define-data-var submission-counter uint u0)

;; Public functions
(define-public (register-oracle)
    (let
        (
            (stake (stx-get-balance tx-sender))
        )
        (asserts! (>= stake min-stake) (err u1)) ;; Ensure minimum stake
        (asserts! (is-none (map-get? oracle-nodes tx-sender)) (err u2)) ;; Check if not already registered
        
        (map-set oracle-nodes tx-sender {
            stake: stake,
            active: true,
            accuracy-score: u100, ;; Initial perfect score
            total-submissions: u0
        })
        (ok true)
    )
)

(define-public (submit-price (price uint))
    (let
        (
            (oracle (map-get? oracle-nodes tx-sender))
            (submission-id (var-get submission-counter))
        )
        ;; Verify oracle is registered and active
        (asserts! (is-some oracle) (err u3))
        (asserts! (get active (unwrap-panic oracle)) (err u4))
        
        ;; Record submission
        (map-set price-submissions submission-id {
            oracle: tx-sender,
            price: price,
            timestamp: block-height,
            verified: false
        })
        
        ;; Increment submission counter
        (var-set submission-counter (+ submission-id u1))
        (ok submission-id)
    )
)

;; Read-only functions
(define-read-only (get-oracle-status (oracle-address principal))
    (map-get? oracle-nodes oracle-address)
)

(define-read-only (get-submission (submission-id uint))
    (map-get? price-submissions submission-id)
)

;; Administrative functions
(define-public (deactivate-oracle (oracle-address principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) (err u5))
        (match (map-get? oracle-nodes oracle-address)
            oracle-data (begin
                (map-set oracle-nodes oracle-address 
                    (merge oracle-data { active: false })
                )
                (ok true)
            )
            (err u6)
        )
    )
)